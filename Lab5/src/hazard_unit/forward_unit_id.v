`include "src/defines.v"

module ForwardUnitID (
    input branch_id, jal_id, jalr_id,
    input reg_write_mem,
    input [4:0] rd_mem, rs1_id, rs2_id,
    output rs1_fwd, rs2_fwd
);
    
    assign rs1_fwd = (rs1_id == `ZERO_REG) ? 1'b0 :
                     branch_id ? ((rd_mem == rs1_id) && reg_write_mem) :
                     jalr_id ? (rd_mem == rs1_id) :
                     0;
    assign rs2_fwd = (rs2_id == `ZERO_REG) ? 1'b0 :
                     branch_id ? ((rd_mem == rs2_id) && reg_write_mem) :
                     0;

endmodule