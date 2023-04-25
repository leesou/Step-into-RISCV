module RAM (
    input clk,
    input write_enable,
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
);

    parameter LEN = 10;
    reg [31:0] mem_core [0:LEN-1];

    initial 
    begin
        $readmemh("tb/ram_data.hex", mem_core);
    end

    // write data to memory
    always @(posedge clk) 
    begin
        if(write_enable)
        begin
            mem_core[addr>>2] <= data_in;
        end    
    end

    // read data from memory
    assign data_out = mem_core[addr>>2];

endmodule