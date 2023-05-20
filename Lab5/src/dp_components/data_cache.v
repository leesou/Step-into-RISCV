`define LRU 1 // comment out this macro to close LRU replacement policy

`ifdef LRU
    `define MAX_AGE 32'h7fffffff
`endif 

module DataCache #(
    parameter LINE_ADDR_LEN = 3, // Each cache line has 2^LINE_ADDR_LEN words
    parameter SET_ADDR_LEN = 3, // This cache has 2^SET_ADDR_LEN cache sets
    parameter TAG_ADDR_LEN = 10, // should in alignment with main memory's space
    parameter WAY_CNT = 4 // each cache set contains WAY_CNT cache lines
) (
    input clk, rst, debug,
    // ports between cache and CPU
    input read_request, write_request,
    input [2:0] write_type,
    input [31:0] addr, write_data,
    output reg request_finish,
    output reg [31:0] read_data,
    // ports between cache and main memory
    output mem_read_request, mem_write_request,
    output [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data,
    output [31:0] mem_addr,
    input mem_request_finish,
    input [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data
);
    // params to transfer bit number to count
    localparam WORD_ADDR_LEN = 2; // each word contains 4 bytes
    localparam MEM_ADDR_LEN = TAG_ADDR_LEN + SET_ADDR_LEN; // in cache line's granularity
    localparam UNUSED_ADDR_LEN = 32 - MEM_ADDR_LEN - LINE_ADDR_LEN - WORD_ADDR_LEN;
    localparam LINE_SIZE = 1 << LINE_ADDR_LEN; // each cache line has LINE_SIZE words
    localparam SET_SIZE = 1 << SET_ADDR_LEN; // This cache has SET_SIZE cache sets
    // cache state enumarations
    parameter [1:0] READY = 2'b00;
    parameter [1:0] REPLACE_OUT = 2'b01;
    parameter [1:0] REPLACE_IN = 2'b10;

    // cache units declaration
    reg [31:0]             cache_data [0:SET_SIZE-1][0:WAY_CNT-1][0:LINE_SIZE-1];
    reg [TAG_ADDR_LEN-1:0] tag [0:SET_SIZE-1][0:WAY_CNT-1];
    reg                    valid [0:SET_SIZE-1][0:WAY_CNT-1];
    reg                    dirty [0:SET_SIZE-1][0:WAY_CNT-1];
    // for replace policy, basically, we will implement FIFO policy
    // For simplicity, we can assign cache lines from way 0 to way WAY_CNT-1
    // In this way, FIFO is equivalant to round-robbin policy
    reg [31:0] replace_way [0:SET_SIZE-1];
    // current cache state
    reg [1:0] cache_state;
    // for LRU, we need to record the age of each way in each set, and the way with the biggest age
`ifdef LRU
    // record each way's age
    reg [31:0] way_age [0:SET_SIZE-1][0:WAY_CNT-1];
`endif

    // Used for memory read/write ports' unpack/pack
    reg [31:0] mem_write_line [0:LINE_SIZE-1];
    wire [31:0] mem_read_line [0:LINE_SIZE-1];
    genvar line;
    generate
        for(line=0; line<LINE_SIZE; line=line+1)
        begin : memory_interface
            assign mem_write_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)] = mem_write_line[line];
            assign mem_read_line[line] = mem_read_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)];
        end
    endgenerate

    // address translation
    wire [UNUSED_ADDR_LEN-1:0] unused_addr;
    wire [TAG_ADDR_LEN-1:0]    tag_addr;
    wire [SET_ADDR_LEN-1:0]    set_addr;
    wire [LINE_ADDR_LEN-1:0]   line_addr;
    wire [WORD_ADDR_LEN-1:0]   word_addr;
    assign {unused_addr, tag_addr, set_addr, line_addr, word_addr} = addr;
    
    // check whether current request hits cache line
    // if cache hits, record the way hit by this request
    reg hit;
    reg [31:0] hit_way;
    integer way;
    always @(*)
    begin
        hit = 1'b0;
        hit_way = WAY_CNT;
        for(way=0; way<WAY_CNT; way=way+1)
        begin
            if(valid[set_addr][way] && (tag[set_addr][way]==tag_addr))
            begin
                hit = 1'b1;
                hit_way = way;
            end
            // else
            // begin
            //     hit = 1'b0;
            //     hit_way = WAY_CNT;
            // end
        end
    end

`ifdef LRU
    // combination logic to choose the way with max age
    reg [31:0] max_age;
    reg [31:0] max_age_way;
    integer age_way;
    always @(*) 
    begin
        max_age = way_age[set_addr][0];
        max_age_way = 0;
        for(age_way=0; age_way<WAY_CNT; age_way=age_way+1)
        begin
            if(way_age[set_addr][age_way]>max_age)
            begin
                max_age = way_age[set_addr][age_way];
                max_age_way = age_way;
            end
        end
    end
`endif

    // when cache miss occurs, tag/set of replaced/target cache line should be buffered  
    reg [TAG_ADDR_LEN-1:0] request_tag_addr, replace_tag_addr;
    reg [SET_ADDR_LEN-1:0] request_set_addr, replace_set_addr;
    reg read_delay, write_delay;
    // cache state machine update logic
    integer i, j, k;
    always @(posedge clk)
    begin
        if(rst)
        begin
            // init CPU-cache interfaces
            request_finish <= 1'b0;
            read_data <= 32'h00000000;
            
            // init cache state
            cache_state <= READY;
            
            // init cache lines
            for(i=0; i<SET_SIZE; i=i+1)
            begin
                replace_way[i] <= 0;
                for(j=0; j<WAY_CNT; j=j+1)
                begin
                    valid[i][j] <= 1'b0;
                    dirty[i][j] <= 1'b0;
`ifdef LRU
                    way_age[i][j] <= `MAX_AGE;
`endif 
                end
            end
            
            // init cache-memory interfaces
            for(k=0; k<LINE_SIZE; k=k+1)
            begin
                mem_write_line[k] <= 32'h00000000;
            end

            request_tag_addr <= 0; replace_tag_addr <= 0;
            request_set_addr <= 0; replace_set_addr <= 0;
            read_delay <= 0; write_delay <= 0;
        end

        else
        begin
            case (cache_state)
                READY:
                begin
                    if(hit)
                    begin
                        // notify CPU the request can be finished
                        request_finish <= (read_request && !read_delay) ? 1'b1 :
                                          (write_request && !write_delay) ? 1'b1 :
                                          1'b0;
                        // update cache data
                        // for read request, fetch corresponding data
                        // for write request, dirty bit should also be updated
                        if(read_request)
                        begin
                            read_delay <= ~read_delay;
                            write_delay <= 0;
                            read_data <= cache_data[set_addr][hit_way][line_addr];
                        end
                        else if(write_request)
                        begin
                            write_delay <= ~write_delay;
                            read_delay <= 0;
                            dirty[set_addr][hit_way] <= 1'b1;
                            if(write_type == `SB)
                            begin
                                if(word_addr == 2'b00)
                                begin
                                    cache_data[set_addr][hit_way][line_addr][31:24] <= write_data[7:0];
                                end
                                else if(word_addr == 2'b01)
                                begin
                                    cache_data[set_addr][hit_way][line_addr][23:16] <= write_data[7:0];
                                end
                                else if(word_addr == 2'b10)
                                begin
                                    cache_data[set_addr][hit_way][line_addr][15:8] <= write_data[7:0];
                                end
                                else if(word_addr == 2'b11)
                                begin
                                    cache_data[set_addr][hit_way][line_addr][7:0] <= write_data[7:0];
                                end
                            end
                            else if(write_type == `SH)
                            begin
                                if(word_addr[1] == 1'b0)
                                begin
                                    cache_data[set_addr][hit_way][line_addr][31:16] <= write_data[15:0];
                                end
                                else if(word_addr[1] == 1'b1)
                                begin
                                    cache_data[set_addr][hit_way][line_addr][15:0] <= write_data[15:0];
                                end
                            end
                            else if(write_type == `SW)
                            begin
                                cache_data[set_addr][hit_way][line_addr] <= write_data;
                            end
                        end
                        else
                        begin
                            read_delay <= 1'b0;
                            write_delay <= 1'b0;
                            read_data <= 32'h00000000;
                        end

`ifdef LRU
                        // update cache age and replace way for LRU
                        if(read_request || write_request)
                        begin
                            if(read_delay || write_delay)
                            begin
                                replace_way[set_addr] <= max_age_way;
                            end
                            else
                            begin
                                for(j=0; j<WAY_CNT; j=j+1)
                                begin
                                    if(j==hit_way)
                                    begin
                                        way_age[set_addr][j] <= 32'h00000000;
                                    end
                                    else
                                    begin
                                        if(way_age[set_addr][j]<`MAX_AGE)
                                        begin
                                            way_age[set_addr][j] <= way_age[set_addr][j]+1;
                                        end
                                    end
                                end
                            end
                        end
`endif
                    end

                    else
                    begin
                        request_finish <= 1'b0;
                        read_delay <= 1'b0;
                        write_delay <= 1'b0;
                        // if current request does not hit
                        if(read_request || write_request)
                        begin
                            // record current request's address
                            request_set_addr <= set_addr;
                            request_tag_addr <= tag_addr;
                            // write back target cache line if it is dirty
                            // then change cache state accordingly
                            if(valid[set_addr][replace_way[set_addr]] && dirty[set_addr][replace_way[set_addr]])
                            begin
                                replace_set_addr <= set_addr;
                                replace_tag_addr <= tag[set_addr][replace_way[set_addr]];
                                for(i=0; i<LINE_SIZE; i=i+1)
                                begin
                                    mem_write_line[i] <= cache_data[set_addr][replace_way[set_addr]][i];
                                end
                                cache_state <= REPLACE_OUT;
                            end
                            else
                            begin
                                cache_state <= REPLACE_IN;
                            end
                        end
                    end
                end 
                
                REPLACE_OUT:
                begin
                    request_finish <= 1'b0;
                    if(mem_request_finish)
                    begin
                        cache_state <= REPLACE_IN;
                    end
                end 

                REPLACE_IN:
                begin
                    // we have to fetch data at the next cycle
                    // in this state, the request is still not ready, even though memory access has finished
                    request_finish <= 1'b0;
                    if(mem_request_finish)
                    begin
                        // update cache line: data, tag, valid, dirty
                        for(i=0; i<LINE_SIZE; i=i+1)
                        begin
                            cache_data[request_set_addr][replace_way[request_set_addr]][i] <= mem_read_line[i];
                        end
                        tag[request_set_addr][replace_way[request_set_addr]] <= request_tag_addr;
                        valid[request_set_addr][replace_way[request_set_addr]] <= 1'b1;
                        dirty[request_set_addr][replace_way[request_set_addr]] <= 1'b0;
`ifndef LRU
                        // for FIFO:
                        // update swap line
                        // we use round-robbin to select the next line
                        // such rule is equivalent to FIFO
                        if(replace_way[request_set_addr] == WAY_CNT-1)
                        begin
                            replace_way[request_set_addr] <= 32'h00000000;
                        end
                        else
                        begin
                            replace_way[request_set_addr] <= replace_way[request_set_addr] + 1;
                        end
`endif
                        // update cache state
                        cache_state <= READY;
                    end
                end
            endcase
        end
    end

    // interact with memory interface
    wire [31:0] read_addr = {request_tag_addr, request_set_addr} << (LINE_ADDR_LEN + WORD_ADDR_LEN);
    wire [31:0] write_addr = {replace_tag_addr, replace_set_addr} << (LINE_ADDR_LEN + WORD_ADDR_LEN);
    wire read_request_wire = (cache_state == REPLACE_IN);
    wire write_request_wire = (cache_state == REPLACE_OUT);
    // send to main memory
    assign mem_read_request = read_request_wire;
    assign mem_write_request = write_request_wire;
    assign mem_addr = read_request_wire ? read_addr :
                      write_request_wire ? write_addr :
                      0;



    integer out_file;
    initial 
    begin
        out_file = $fopen("cache.txt", "w");    
    end

    integer set_index, way_index, line_index;
    always @(posedge clk) 
    begin
        if(debug)
        begin
            for(set_index=0; set_index<SET_SIZE; set_index=set_index+1)
            begin
                for(way_index=0; way_index<WAY_CNT; way_index=way_index+1)
                begin
                    $fwrite(out_file, "%d %d %8h ", valid[set_index][way_index], dirty[set_index][way_index], tag[set_index][way_index]);
`ifdef LRU
                    $fwrite(out_file, "%8h ", way_age[set_index][way_index]);
`endif 
                    for(line_index=0; line_index<LINE_SIZE; line_index=line_index+1)
                    begin
                        $fwrite(out_file, "%8h ", cache_data[set_index][way_index][line_index]);
                    end
                    $fwrite(out_file, "\n");
                end
                $fwrite(out_file, "\n");
            end
        end    
    end

    // for debug
    // wire target_valid = hit ? valid[request_set_addr][hit_way] : 1'b0;
    // wire target_dirty = dirty[request_set_addr][hit_way];
    // wire [TAG_ADDR_LEN-1:0] target_tag = tag[request_set_addr][hit_way];
    // wire [31:0] target_replace_way = replace_way[request_set_addr];
    // wire [255:0] taeget_cache_line_data = {cache_data[request_set_addr][hit_way][0], cache_data[request_set_addr][hit_way][1], cache_data[request_set_addr][hit_way][2], cache_data[request_set_addr][hit_way][3],
    //                                         cache_data[request_set_addr][hit_way][4], cache_data[request_set_addr][hit_way][5], cache_data[request_set_addr][hit_way][6], cache_data[request_set_addr][hit_way][7]};


endmodule