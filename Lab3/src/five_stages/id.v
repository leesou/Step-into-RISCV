`include "src/dp_components/regfile.v"
`include "src/dp_components/imm_gen.v"
`include "src/cp_components/control_unit.v"
`include "src/cp_components/alu_control.v"

module InstructionDecode (
    input clk,
    input [31:0] instr,
    input [31:0] reg_write_data,
    // for ALU in execution stage
    output alu_src1, alu_src2,
    output [31:0] rs1_data, rs2_data, imm,
    output [3:0] alu_type,
    // for global control
    output branch, jal, jalr, mem_read, mem_write,
    output [1:0] reg_src,
    output [2:0] branch_type, load_type, store_type
);
    // break down the instruction
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [2:0] funct3 = instr[14:12];
    wire instr30 = instr[30];

    // intermediate wires
    wire reg_write;
    wire [1:0] alu_op;

    // control path in ID
    ControlUnit control_unit(
        .opcode(opcode),
        .branch(branch), .jal(jal), .jalr(jalr),
        .mem_read(mem_read), .mem_write(mem_write),
        .alu_src1(alu_src1), .alu_src2(alu_src2),
        .reg_write(reg_write),
        .reg_src(reg_src),
        .alu_op(alu_op)
    );
    ALUControl alu_control(
        .alu_op(alu_op),
        .instr30(instr30),
        .funct3(funct3),
        .alu_type(alu_type)
    );
    assign branch_type = funct3;
    assign load_type = funct3;
    assign store_type = funct3;

    // data path in ID
    RegFile reg_file(
        .clk(clk),
        .write_enable(reg_write),
        .read_addr1(rs1), .read_addr2(rs2), .write_addr(rd),
        .write_data(reg_write_data),
        .read_data1(rs1_data), .read_data2(rs2_data)
    );
    ImmGen imm_gen(
        .instr(instr),
        .imm(imm)
    );

endmodule