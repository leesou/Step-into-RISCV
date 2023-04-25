`include "src/defines.v"

module ControlUnit (
    input [6:0] opcode,
    output branch, jump,
    output mem_read, mem_to_reg, mem_write,
    output alu_src,
    output reg_write,
    output [1:0] alu_op
);
    assign branch = (opcode == `INST_TYPE_B) ? 1 : 0;
    assign jump = (opcode == `INST_JAL) ? 1 :
                  (opcode == `INST_JALR) ? 1 : 0;
    assign mem_read = (opcode == `INST_TYPE_L) ? 1 : 0;
    assign mem_to_reg = (opcode == `INST_TYPE_L) ? 1 : 0;
    assign mem_write = (opcode == `INST_TYPE_S) ? 1 : 0;
    assign alu_src = (opcode == `INST_TYPE_I) ? 1 : 
                     (opcode == `INST_TYPE_L) ? 1 :
                     (opcode == `INST_TYPE_S) ? 1 :
                     (opcode == `INST_JALR) ? 1 : 0;
    assign reg_write = (opcode == `INST_TYPE_I) ? 1 :
                       (opcode == `INST_TYPE_L) ? 1 :
                       (opcode == `INST_TYPE_R) ? 1 :
                       (opcode == `INST_JAL) ? 1 :
                       (opcode == `INST_JALR) ? 1 :
                       (opcode == `INST_LUI) ? 1 :
                       (opcode == `INST_AUIPC) ? 1 : 0;
    assign alu_op = (opcode == `INST_TYPE_B) ? 2'b01 :
                   (opcode == `INST_TYPE_I) ? 2'b10 :
                   (opcode == `INST_TYPE_R) ? 2'b10 :
                   2'b00;
endmodule