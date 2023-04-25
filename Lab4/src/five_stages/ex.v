`include "src/dp_components/alu.v"
// `include "src/dp_components/pc_ex.v"
`include "src/defines.v"

module Execute (
    // input branch, jal, jalr,
    // input [2:0] branch_type,
    input alu_src1, alu_src2,
    input [3:0] alu_type,
    input [31:0] pc, rs1_data, rs2_data, imm,
    // output pc_src,
    output [31:0] alu_result, //new_pc,
    // for data hazard
    input [1:0] rs1_sel, rs2_sel,
    input [31:0] mem_fwd_data, wb_fwd_data,
    output [31:0] rs2_data_real
);
    wire zero, less_than;

    // select real rs1/rs2 data
    wire [31:0] rs1_real = (rs1_sel == `FWD_MEM) ? mem_fwd_data :
                           (rs1_sel == `FWD_WB) ? wb_fwd_data :
                           rs1_data;
    wire [31:0] rs2_real = (rs2_sel == `FWD_MEM) ? mem_fwd_data :
                           (rs2_sel == `FWD_WB) ? wb_fwd_data :
                           rs2_data;   
    assign rs2_data_real = rs2_real;                 

    // select operation datas for ALU
    wire [31:0] op1, op2;
    assign op1 = alu_src1 ? pc : rs1_real;
    assign op2 = alu_src2 ? imm : rs2_real;

    // ALU module
    ALU alu(
        .alu_type(alu_type), 
        .data_in1(op1), .data_in2(op2),
        .data_out(alu_result),
        .zero(zero), .less_than(less_than)
    );

    // moved to ID stage for control hazard
    // PC Execution module
    // PCExecute pc_execute(
    //     .branch(branch), .jal(jal), .jalr(jalr),
    //     .branch_type(branch_type),
    //     .zero(zero), .less_than(less_than),
    //     .pc(pc), .imm(imm), .rs1_data(rs1_data),
    //     .pc_src(pc_src),
    //     .new_pc(new_pc)
    // );
    
endmodule