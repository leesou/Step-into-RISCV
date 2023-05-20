
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

    // current cache state
    reg [1:0] cache_state;

    // for replace policy, basically, we will implement FIFO policy
    // For simplicity, we can assign cache lines from way 0 to way WAY_CNT-1
    // In this way, FIFO is equivalant to round-robbin policy
    reg [31:0] replace_way [0:SET_SIZE-1];
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
    /*****************************************
     *                                       *
     *     FILL WITH YOUR IMPLEMENTATION     *
     *                                       *
     *****************************************/
    

    // check whether current request hits cache line
    // if cache hits, record the way hit by this request
    /*****************************************
     *                                       *
     *     FILL WITH YOUR IMPLEMENTATION     *
     *                                       *
     *****************************************/


`ifdef LRU
    // combination logic to choose the way with max age
    /*****************************************
     *                                       *
     *     FILL WITH YOUR IMPLEMENTATION     *
     *                                       *
     *****************************************/
`endif


    // interact with memory interface when cache miss/replacement occurs
    /*****************************************
     *                                       *
     *     FILL WITH YOUR IMPLEMENTATION     *
     *                                       *
     *****************************************/


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
        end

        else
        begin
            case (cache_state)
                READY:
                begin
                    if(hit)
                    begin
                        // notify CPU whether the request can be finished
                        /*****************************************
                         *                                       *
                         *     FILL WITH YOUR IMPLEMENTATION     *
                         *                                       *
                         *****************************************/

                        // update cache data
                        // for read request, fetch corresponding data
                        // for write request, dirty bit should also be updated
                        if(read_request)
                        begin
                            /*****************************************
                             *                                       *
                             *     FILL WITH YOUR IMPLEMENTATION     *
                             *                                       *
                             *****************************************/
                        end
                        else if(write_request)
                        begin
                            /*****************************************
                             *                                       *
                             *     FILL WITH YOUR IMPLEMENTATION     *
                             *                                       *
                             *****************************************/
                        end
                        else
                        begin
                            read_data <= 32'h00000000;
                        end

                        // update cache age and replace way for LRU
                        /*****************************************
                         *                                       *
                         *     FILL WITH YOUR IMPLEMENTATION     *
                         *                                       *
                         *****************************************/
                    end

                    else
                    begin
                        // if current request does not hit, change cache state
                        /*****************************************
                         *                                       *
                         *     FILL WITH YOUR IMPLEMENTATION     *
                         *                                       *
                         *****************************************/
                    end
                end 
                
                REPLACE_OUT:
                begin
                    // switch to REPLACE_IN when memory write finishes
                    /*****************************************
                     *                                       *
                     *     FILL WITH YOUR IMPLEMENTATION     *
                     *                                       *
                     *****************************************/
                end 

                REPLACE_IN:
                begin
                    // When memory read finishes, fill in corresponding cache line,
                    // set the cache line's state, then swtich to READY
                    // From the next cycle, the request is hit.
                    /*****************************************
                     *                                       *
                     *     FILL WITH YOUR IMPLEMENTATION     *
                     *                                       *
                     *****************************************/
                end
            endcase
        end
    end



    // for your ease of debug
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

endmodule