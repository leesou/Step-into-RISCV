`include "src/defines.v"

module FowardUnitEX (
    input reg_write_mem, reg_write_wb,
    input [4:0] rd_mem, rd_wb,
    input [4:0] rs1_ex, rs2_ex,
    output [1:0] rs1_fwd, rs2_fwd
);

    // MEM's forwarding is in previlidge to WB's
    // A stage needs WB: (1) reg_write in this stage is true (2) rd in this stage is equal to rs1/rs2 in EX stage

    wire rs1_wb_fwd = (reg_write_wb) ? ((rd_wb == rs1_ex) ? 1 : 0) : 0;
    wire rs1_mem_fwd = (reg_write_mem) ? ((rd_mem == rs1_ex) ? 1 : 0) : 0; 
    assign rs1_fwd = (rs1_ex == `ZERO_REG) ? `NO_FWD :
                     (rs1_mem_fwd) ? `FWD_MEM :
                     (rs1_wb_fwd) ? `FWD_WB :
                     `NO_FWD;
    
    wire rs2_wb_fwd = (reg_write_wb) ? ((rd_wb == rs2_ex) ? 1 : 0) : 0;
    wire rs2_mem_fwd = (reg_write_mem) ? ((rd_mem == rs2_ex) ? 1 : 0) : 0; 
    assign rs2_fwd = (rs2_ex == `ZERO_REG) ? `NO_FWD :
                     (rs2_mem_fwd) ? `FWD_MEM :
                     (rs2_wb_fwd) ? `FWD_WB :
                     `NO_FWD;

endmodule