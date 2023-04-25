`include "src/defines.v"

module ImmGen (
    input [31:0] instr,
    output [31:0] imm
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];

    wire [31:0] itype_imm = (funct3 == `SR_FUNCT3) ? {27'b0, instr[24:20]} :
                            (funct3 == `SLL_FUNCT3) ? {27'b0, instr[24:20]} :
                            {{20{instr[31]}}, instr[31:20]};
    assign imm = (opcode == `INST_TYPE_B) ? {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} :
                 (opcode == `INST_TYPE_L) ? {{20{instr[31]}}, instr[31:20]} :
                 (opcode == `INST_TYPE_S) ? {{20{instr[31]}}, instr[31:25], instr[11:7]} :
                 (opcode == `INST_TYPE_I) ? itype_imm :
                 (opcode == `INST_LUI) ? {instr[31:12], 12'b0} :
                 (opcode == `INST_AUIPC) ? {instr[31:12], 12'b0} :
                 (opcode == `INST_JAL) ? {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0} :
                 (opcode == `INST_JALR) ? {{20{instr[31]}}, instr[31:20]} :
                 32'h00000000;


endmodule