`include "src/defines.v"

module ControlUnit (
    input [6:0] opcode,
    output branch, jal, jalr,
    output mem_read, mem_write,
    output alu_src1, alu_src2,
    output reg_write,
    output [1:0] reg_src, // Extension for MemtoReg
    output [1:0] alu_op
);
    assign branch = (opcode == `INST_TYPE_B) ? 1 : 0;
    assign jal = (opcode == `INST_JAL) ? 1 : 0;
    assign jalr = (opcode == `INST_JALR) ? 1 : 0;
    assign mem_read = (opcode == `INST_TYPE_L) ? 1 : 0;
    assign mem_write = (opcode == `INST_TYPE_S) ? 1 : 0;
    assign alu_src1 = (opcode == `INST_AUIPC) ? 1 : 0;
    assign alu_src2 = (opcode == `INST_TYPE_I) ? 1 : 
                     (opcode == `INST_TYPE_L) ? 1 :
                     (opcode == `INST_TYPE_S) ? 1 :
                     (opcode == `INST_AUIPC) ? 1 :
                     (opcode == `INST_LUI) ? 1 : 0;
    assign reg_write = (opcode == `INST_TYPE_I) ? 1 :
                       (opcode == `INST_TYPE_L) ? 1 :
                       (opcode == `INST_TYPE_R) ? 1 :
                       (opcode == `INST_JAL) ? 1 :
                       (opcode == `INST_JALR) ? 1 :
                       (opcode == `INST_LUI) ? 1 :
                       (opcode == `INST_AUIPC) ? 1 : 0;
    assign reg_src = (opcode == `INST_TYPE_R) ? `FROM_ALU :
                     (opcode == `INST_TYPE_I) ? `FROM_ALU :
                     (opcode == `INST_AUIPC) ? `FROM_ALU :
                     (opcode == `INST_TYPE_L) ? `FROM_MEM :
                     (opcode == `INST_LUI) ? `FROM_IMM :
                     (opcode == `INST_JAL) ? `FROM_PC :
                     (opcode == `INST_JALR) ? `FROM_PC : 0;
    assign alu_op = (opcode == `INST_TYPE_B) ? `ALU_OP_B :
                   (opcode == `INST_TYPE_I) ? `ALU_OP_I :
                   (opcode == `INST_TYPE_R) ? `ALU_OP_R :
                   2'b00;
endmodule