`include "src/defines.v"
// `include "src/templates/pipe_dff.v"

module MEMWB (
    input clk, bubble, stall,

    input [31:0] mem_to_reg_data_mem,
    // hold for next stages
    input reg_write_mem,
    input [1:0] reg_src_mem,
    input [4:0] rd_mem,
    input [31:0] alu_result_mem, imm_mem, nxpc_mem,

    output [31:0] mem_to_reg_data_wb,
    // hold for next stages
    output reg_write_wb,
    output [1:0] reg_src_wb,
    output [4:0] rd_wb,
    output [31:0] alu_result_wb, imm_wb, nxpc_wb
);

    PipeDff #(32) mem_to_reg_data_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(mem_to_reg_data_mem),
        .data_out(mem_to_reg_data_wb)
    );

    PipeDff #(1) reg_write_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(reg_write_mem),
        .data_out(reg_write_wb)
    );
    PipeDff #(2) reg_src_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(2'b00), .data_in(reg_src_mem),
        .data_out(reg_src_wb)
    );
    PipeDff #(5) rd_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(5'b00000), .data_in(rd_mem),
        .data_out(rd_wb)
    );
    PipeDff #(32) alu_result_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(alu_result_mem),
        .data_out(alu_result_wb)
    );
    PipeDff #(32) imm_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(imm_mem),
        .data_out(imm_wb)
    );
    PipeDff #(32) nxpc_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(nxpc_mem),
        .data_out(nxpc_wb)
    );
    
endmodule