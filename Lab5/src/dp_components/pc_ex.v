`include "src/defines.v"

module PCExecute (
    input branch, jal, jalr, 
    input [2:0] branch_type, // from control unit
    input zero, less_than, // from ALU
    input [31:0] pc, imm, rs1_data,
    output pc_src,
    output [31:0] new_pc
);

    // calculate new PC
    assign new_pc = branch ? $signed($signed(pc)+$signed(imm)) :
                    jal ? $signed($signed(pc)+$signed(imm)) :
                    jalr ? $signed($signed(rs1_data)+$signed(imm)) : 
                    pc;

    // check ALU and branch type to decide whether to conduct branch if this is a B-Type instruction
    assign conduct_branch = (branch_type == `BEQ) ? zero :
                            (branch_type == `BNE) ? ~zero :
                            (branch_type == `BLT) ? less_than :
                            (branch_type == `BGE) ? ~less_than :
                            (branch_type == `BLTU) ? less_than :
                            (branch_type == `BGEU) ? ~less_than :
                            0;
    assign pc_src = branch ? conduct_branch :
                    jal ? 1 :
                    jalr ? 1 :
                    0;

    
endmodule