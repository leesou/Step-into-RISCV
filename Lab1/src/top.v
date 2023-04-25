`include "src-lc/alu.v"
`include "src-lc/ram.v"

module TOP (
    input clk,
    input write_enable,
    input [31:0] addr,
    input[31:0] data_in,
    input [3:0] aluop,
    input [31:0] data_in2,
    output [31:0] data_out
);
    wire [31:0] data_in1;
    RAM ram(.clk(clk), .write_enable(write_enable), .addr(addr), .data_in(data_in), .data_out(data_in1));
    ALU alu(.aluop(aluop), .data_in1(data_in1), .data_in2(data_in2), .data_out(data_out));
endmodule