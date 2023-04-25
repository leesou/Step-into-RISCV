`include "src/dp_components/alu.v"
`include "src/dp_components/pc_ex.v"

module Execute (
    input branch, jal, jalr,
    input [2:0] branch_type,
    input alu_src1, alu_src2,
    input [3:0] alu_type,
    input [31:0] pc, rs1_data, rs2_data, imm,
    output pc_src,
    output [31:0] alu_result, new_pc
);
    wire zero, less_than;

    // select operation datas for ALU
    wire [31:0] op1, op2;
    assign op1 = alu_src1 ? pc : rs1_data;
    assign op2 = alu_src2 ? imm : rs2_data;

    // ALU module
    ALU alu(
        .alu_type(alu_type), 
        .data_in1(op1), .data_in2(op2),
        .data_out(alu_result),
        .zero(zero), .less_than(less_than)
    );

    // PC Execution module
    PCExecute pc_execute(
        .branch(branch), .jal(jal), .jalr(jalr),
        .branch_type(branch_type),
        .zero(zero), .less_than(less_than),
        .pc(pc), .imm(imm), .rs1_data(rs1_data),
        .pc_src(pc_src),
        .new_pc(new_pc)
    );
    
endmodule