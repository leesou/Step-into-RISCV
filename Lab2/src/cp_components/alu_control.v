`include "src/defines.v"

module ALUControl (
    input [1:0] alu_op,
    input instr30,
    input [2:0] funct3,
    output [3:0] alu_type
);
    
    assign alu_type = (alu_op == `ALU_OP_IR) ? {instr30, funct3} :
                      (alu_op == `ALU_OP_B) ? `SUB :
                      `ADD;

endmodule