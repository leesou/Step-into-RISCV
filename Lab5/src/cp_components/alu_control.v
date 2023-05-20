`include "src/defines.v"

module ALUControl (
    input [1:0] alu_op,
    input instr30,
    input [2:0] funct3,
    output [3:0] alu_type
);
    // judge branch operation's ALU type
    wire [3:0] /*branch_alu_type,*/ imm_alu_type;
    // assign branch_alu_type = (funct3 == `BEQ) ? `SUB :
    //                          (funct3 == `BNE) ? `SUB :
    //                          (funct3 == `BLT) ? `SLT :
    //                          (funct3 == `BGE) ? `SLT :
    //                          (funct3 == `BLTU) ? `SLTU :
    //                          (funct3 == `BGEU) ? `SLTU :
    //                          `ADD;
    assign imm_alu_type = (funct3 == `SR_FUNCT3) ? {instr30, funct3} : {1'b0, funct3};
    assign alu_type = (alu_op == `ALU_OP_R) ? {instr30, funct3} :
                      (alu_op == `ALU_OP_I) ? imm_alu_type :
                      // (alu_op == `ALU_OP_B) ? branch_alu_type :
                      `ADD;

endmodule