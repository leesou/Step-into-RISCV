`include "src/ram.v"

module MainMemoryWrapper #(
    parameter LINE_ADDR_LEN = 3,
    parameter ADDR_LEN = 13
) (
    input clk, rst, debug,
    input read_request, write_request,
    input [(32*(1<<LINE_ADDR_LEN)-1):0] write_data,
    input [31:0] addr,
    output reg request_finish,
    output [(32*(1<<LINE_ADDR_LEN)-1):0] read_data
);
    localparam WORD_ADDR_LEN = 2;
    // We assume this latency is longer than read/write latency.
    // When these parameters are 17, you can only read/write 15/16 elements at most.
    // Futhermore, if you send read/write requests at the ith cycle,
    // the request_finish will be set high at the (i+19)th cycle,
    // and the memory state will return tu READY at the (i+20)th cycle.
    localparam RD_CYCLE = 17;
    localparam WR_CYCLE = 17;
    localparam LINE_SIZE = 1 << LINE_ADDR_LEN;
    // memory wrapper state machine
    parameter [1:0] READY = 2'b00;
    parameter [1:0] WRITE = 2'b01;
    parameter [1:0] READ = 2'b10;

    wire [31:0] zeros = 32'h00000000;
    
    reg [1:0] mem_state;
    reg [31:0] read_delay, write_delay; // record execution latency of current request

    reg [31:0] tmp_addr; // record addr when access request sends
    reg [31:0] tmp_read_data [0:LINE_SIZE-1]; // only when read finishes this tmp buffer will be assigned to the output
    reg [31:0] tmp_write_data [0:LINE_SIZE-1];

    reg ram_write; // write enable for ram
    reg [31:0] ram_addr; // address sent to ram
    reg [31:0] ram_write_data;
    wire [31:0] ram_read_data;

    wire [31:0] read_index = read_delay - 1;
    wire [31:0] write_index = write_delay - 1;

    // used for read/write ports' pack/unpack
    wire [31:0] write_line [0:LINE_SIZE-1];
    reg [31:0] read_line [0:LINE_SIZE-1];
    genvar line;
    generate
        for(line=0; line<LINE_SIZE; line=line+1)
        begin : memory_interface
            assign write_line[line] = write_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)];
            assign read_data[32*(LINE_SIZE-line)-1:32*(LINE_SIZE-line-1)] = read_line[line];
        end
    endgenerate

    // wrapper state machine
    integer i;
    always @(posedge clk) 
    begin
        if(rst)
        begin
            mem_state <= READY;
            read_delay <= 32'h00000000;
            write_delay <= 32'h00000000;
            
            request_finish <= 1'b0;
            tmp_addr <= 32'h00000000;
            for(i=0; i<(LINE_SIZE); i=i+1)
            begin
                read_line[i] <= 32'h00000000;
                tmp_read_data[i] <= 32'h00000000;
                tmp_write_data[i] <= 32'h00000000;
            end

            ram_write <= 1'b0;
            ram_addr <= 32'h00000000;
            ram_write_data <= 32'h00000000;
        end
        
        else
        begin
            case (mem_state)
                READY:
                begin
                    ram_write <= 1'b0;
                    request_finish <= 1'b0;
                    tmp_addr <= addr;

                    read_delay <= 32'h00000000;
                    write_delay <= 32'h00000000;
                    if(read_request)
                    begin
                        mem_state <= READ;
                        for(i=0; i<(LINE_SIZE); i=i+1)
                        begin
                            tmp_read_data[i] <= 32'h00000000;
                        end
                    end
                    else if(write_request)
                    begin
                        mem_state <= WRITE;
                        for(i=0; i<(LINE_SIZE); i=i+1)
                        begin
                            tmp_write_data[i] <= write_line[i];
                        end
                    end
                end

                WRITE:
                begin
                    read_delay <= 32'h00000000;
                    write_delay <= write_delay + 1;
                    if(write_delay < WR_CYCLE)
                    begin
                        request_finish <= 1'b0;
                        if(write_delay>=1 && write_delay<=LINE_SIZE)
                        begin
                            ram_write <= 1'b1;
                            // ram_addr <= {tmp_addr[31:LINE_ADDR_LEN+WORD_ADDR_LEN], write_index[LINE_ADDR_LEN-1:0], 2'b00};
                            ram_addr <= {zeros[31:28], tmp_addr[27:0]} + {zeros[31:LINE_ADDR_LEN+WORD_ADDR_LEN], write_index[LINE_ADDR_LEN-1:0], 2'b00};
                            ram_write_data <= tmp_write_data[write_index[LINE_ADDR_LEN-1:0]];
                        end
                        else
                        begin
                            ram_write <= 1'b0;
                            ram_addr <= 32'h00000000;
                            ram_write_data <= 32'h00000000;
                        end
                    end
                    else
                    begin
                        ram_write <= 1'b0;
                        if(write_delay==WR_CYCLE)
                        begin
                            request_finish <= 1'b1;
                        end
                        else
                        begin
                            request_finish <= 1'b0;
                            mem_state <= READY;
                        end
                    end
                end 

                READ:
                begin
                    ram_write <= 1'b0;
                    write_delay <= 32'h00000000;
                    read_delay <= read_delay + 1;
                    if(read_delay < RD_CYCLE)
                    begin
                        if(read_delay <= LINE_SIZE)
                        begin
                            // ram_addr <= {tmp_addr[31:LINE_ADDR_LEN+WORD_ADDR_LEN], read_index[LINE_ADDR_LEN-1:0], 2'b00};
                            ram_addr <= {zeros[31:28], tmp_addr[27:0]} + {zeros[31:LINE_ADDR_LEN+WORD_ADDR_LEN], read_index[LINE_ADDR_LEN-1:0], 2'b00};
                        end
                        // posedge FF has to receive data in the next cycle
                        if(read_delay>=2 && read_delay<=LINE_SIZE+1)
                        begin
                            tmp_read_data[read_delay-2] <= ram_read_data;
                        end
                    end
                    else
                    begin
                        if(read_delay==RD_CYCLE)
                        begin
                            for(i=0; i<LINE_SIZE; i=i+1)
                            begin
                                read_line[i] <= tmp_read_data[i];
                            end
                            request_finish <= 1'b1;
                        end
                        else
                        begin
                            request_finish <= 1'b0;
                            for(i=0; i<LINE_SIZE; i=i+1)
                            begin
                                read_line[i] <= 0;
                            end
                            mem_state <= READY;
                        end
                    end
                end
            endcase
        end
    end

    // interact with ram
    RAM ram(
        .clk(clk), .debug(debug),
        .write_enable(ram_write),
        .addr(ram_addr),
        .data_in(ram_write_data),
        .data_out(ram_read_data)
    );



endmodule