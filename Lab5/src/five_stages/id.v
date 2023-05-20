`include "src/dp_components/regfile.v"
`include "src/dp_components/imm_gen.v"
`include "src/dp_components/pc_ex.v"
`include "src/cp_components/control_unit.v"
`include "src/cp_components/alu_control.v"

module InstructionDecode (
    input clk, rst,
    input [31:0] instr,
    input reg_write_in,
    input [4:0] rd_in,
    input [31:0] reg_write_data,
    // for ALU in execution stage
    output alu_src1, alu_src2,
    output [31:0] rs1_data, rs2_data, imm,
    output [3:0] alu_type,
    // for global control
    output branch, jal, jalr,
    output mem_read, mem_write,
    output reg_write_out,
    output [4:0] rd_out,
    output [1:0] reg_src,
    output [2:0] instr_funct3,
    // for data forwarding
    output [4:0] rs1_out, rs2_out,
    // for control hazard
    input [31:0] pc,
    input [31:0] mem_fwd_data,
    input rs1_fwd, rs2_fwd,
    output pc_src,
    output [31:0] new_pc
);
    // break down the instruction
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd = instr[11:7];
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [2:0] funct3 = instr[14:12];
    wire instr30 = instr[30];

    // intermediate wires
    wire [1:0] alu_op;
    // for control hazard
    wire branch_wire, jal_wire, jalr_wire;
    wire zero, less_than;
    wire [31:0] imm_wire, rs1_data_wire, rs2_data_wire;
    wire [31:0] rs1_data_for_branch, rs2_data_for_branch;

    // control path in ID
    ControlUnit control_unit(
        .opcode(opcode),
        .branch(branch_wire), .jal(jal_wire), .jalr(jalr_wire),
        .mem_read(mem_read), .mem_write(mem_write),
        .alu_src1(alu_src1), .alu_src2(alu_src2),
        .reg_write(reg_write_out),
        .reg_src(reg_src),
        .alu_op(alu_op)
    );
    ALUControl alu_control(
        .alu_op(alu_op),
        .instr30(instr30),
        .funct3(funct3),
        .alu_type(alu_type)
    );
    assign instr_funct3 = funct3;
    assign rd_out = rd;
    assign rs1_out = rs1;
    assign rs2_out = rs2;
    assign branch = branch_wire;
    assign jal = jal_wire;
    assign jalr = jalr_wire;

    // data path in ID
    RegFile reg_file(
        .clk(clk), .rst(rst),
        .write_enable(reg_write_in),
        .read_addr1(rs1), .read_addr2(rs2), .write_addr(rd_in),
        .write_data(reg_write_data),
        .read_data1(rs1_data_wire), .read_data2(rs2_data_wire)
    );
    assign rs1_data = rs1_data_wire;
    assign rs2_data = rs2_data_wire;
    ImmGen imm_gen(
        .instr(instr),
        .imm(imm_wire)
    );
    assign imm = imm_wire;

    // for control hazard
    assign rs1_data_for_branch = rs1_fwd ? mem_fwd_data : rs1_data_wire;
    assign rs2_data_for_branch = rs2_fwd ? mem_fwd_data : rs2_data_wire;
    assign zero = (rs1_data_for_branch == rs2_data_for_branch) ? 1 : 0;
    assign less_than = ((funct3 == `BLT) || (funct3 == `BGE)) ? $signed(rs1_data_for_branch)<$signed(rs2_data_for_branch) :
                       ((funct3 == `BLTU) || (funct3 == `BGEU)) ? rs1_data_for_branch<rs2_data_for_branch :
                       0;
    PCExecute pc_execute(
        .branch(branch), .jal(jal), .jalr(jalr),
        .branch_type(funct3),
        .zero(zero), .less_than(less_than),
        .pc(pc), .imm(imm_wire), .rs1_data(rs1_data_for_branch),
        .pc_src(pc_src),
        .new_pc(new_pc)
    );

endmodule