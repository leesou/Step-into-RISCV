`include "src/defines.v"
// `include "src/templates/pipe_dff.v"

module EXMEM (
    input clk, bubble, stall,

    // control signals
    // input pc_src_ex,
    // data alues
    // input [31:0] new_pc_ex, 
    input [31:0] alu_result_ex,
    // hold for future stages
    input mem_read_ex, mem_write_ex, reg_write_ex,
    input [1:0] reg_src_ex,
    input [2:0] instr_funct3_ex,
    input [4:0] rd_ex,
    input [31:0] rs2_data_ex, imm_ex, nxpc_ex,

    // control signals
    // output pc_src_mem,
    // data alues
    // output [31:0] new_pc_mem,
    output [31:0] alu_result_mem,
    // hold for future stages
    output mem_read_mem, mem_write_mem, reg_write_mem,
    output [1:0] reg_src_mem,
    output [2:0] instr_funct3_mem,
    output [4:0] rd_mem,
    output [31:0] rs2_data_mem, imm_mem, nxpc_mem
);

    // PipeDff #(1) pc_src_dff(
    //     .clk(clk), .bubble(bubble), .stall(stall),
    //     .default_val(1'b0), .data_in(pc_src_ex),
    //     .data_out(pc_src_mem)
    // );

    // PipeDff #(32) new_pc_dff(
    //     .clk(clk), .bubble(bubble), .stall(stall),
    //     .default_val(`ZERO_WORD), .data_in(new_pc_ex),
    //     .data_out(new_pc_mem)
    // );
    PipeDff #(32) alu_result_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(alu_result_ex),
        .data_out(alu_result_mem)
    );

    PipeDff #(1) mem_read_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(mem_read_ex),
        .data_out(mem_read_mem)
    );
    PipeDff #(1) mem_write_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(mem_write_ex),
        .data_out(mem_write_mem)
    );
    PipeDff #(1) reg_write_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(reg_write_ex),
        .data_out(reg_write_mem)
    );
    PipeDff #(2) reg_src_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(2'b00), .data_in(reg_src_ex),
        .data_out(reg_src_mem)
    );
    PipeDff #(3) instr_funct3_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(3'b000), .data_in(instr_funct3_ex),
        .data_out(instr_funct3_mem)
    );
    PipeDff #(5) rd_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(5'b00000), .data_in(rd_ex),
        .data_out(rd_mem)
    );
    PipeDff #(32) rs2_data_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(rs2_data_ex),
        .data_out(rs2_data_mem)
    );
    PipeDff #(32) imm_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(imm_ex),
        .data_out(imm_mem)
    );
    PipeDff #(32) nxpc_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(nxpc_ex),
        .data_out(nxpc_mem)
    );

    
endmodule