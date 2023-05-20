`include "src/defines.v"
// `include "src/templates/pipe_dff.v"

module IFID (
    input clk, bubble, stall, 
    input [31:0] instr_if, pc_if, nxpc_if,
    output [31:0] instr_id, pc_id, nxpc_id
);

    PipeDff #(32) instr_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`INST_NOP), .data_in(instr_if),
        .data_out(instr_id)
    );
    PipeDff #(32) pc_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(pc_if),
        .data_out(pc_id)
    );
    PipeDff #(32) nxpc_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(nxpc_if),
        .data_out(nxpc_id)
    );
    
endmodule