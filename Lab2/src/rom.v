module ROM (
    input clk,
    input [31:0] addr,
    output [31:0] data_out
);
    parameter LEN = 65536;
    reg [31:0] mem_core [0:LEN-1];

    initial 
    begin
         $readmemh("tb/rom_data.hex", mem_core);
    end

    assign data_out = mem_core[addr>>2];

endmodule