`include "src/cp_components/alu_control.v"
`include "src/cp_components/control_unit.v"
`include "src/dp_components/pc.v"
`include "src/dp_components/regfile.v"
`include "src/template/adder.v"
`include "src/rom.v"

module TOP (
    input clk, rst,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2,
    output branch, jump, 
    output mem_read, mem_to_reg, mem_write,
    output alu_src,
    output [3:0] alu_type,
    // output for verification
    output reg_write_enable,
    output [31:0] instr_out 
);
    wire [31:0] pc, nxpc;
    wire [31:0] pc_incre = 32'h00000004;
    wire [31:0] instr;

    wire reg_write;
    wire[1:0] alu_op;

    // instruction fetch
    PC pc_reg(.clk(clk), .rst(rst), .pc_in(nxpc), .pc_out(pc));
    Adder #(32) adder(.data_in1(pc), .data_in2(pc_incre), .data_out(nxpc));
    ROM instr_rom(.clk(clk), .addr(pc), .data_out(instr));

    // instruction decode
    RegFile reg_file(
        .clk(clk), .write_enable(reg_write), 
        .read_addr1(instr[19:15]), .read_addr2(instr[24:20]), .write_addr(instr[11:7]),
        .write_data(write_data),
        .read_data1(read_data1), .read_data2(read_data2)
    );
    ControlUnit control_unit(
        .opcode(instr[6:0]),
        .branch(branch), .jump(jump),
        .mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write),
        .alu_src(alu_src), .reg_write(reg_write),
        .alu_op(alu_op)
    );
    ALUControl alu_control(
        .alu_op(alu_op), .instr30(instr[30]), .funct3(instr[14:12]),
        .alu_type(alu_type)
    );

    // output for verification
    assign instr_out = instr;
    assign reg_write_enable = reg_write;
    
endmodule