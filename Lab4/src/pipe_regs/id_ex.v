`include "src/defines.v"
// `include "src/templates/pipe_dff.v"

module IDEX (
    input clk, bubble, stall,

    // control signals
    //input branch_id, jal_id, jalr_id,
    input mem_read_id, mem_write_id,
    input alu_src1_id, alu_src2_id,
    input reg_write_id,
    input [1:0] reg_src_id,
    input [2:0] instr_funct3_id,
    input [3:0] alu_type_id,
    input [4:0] rd_id, rs1_id, rs2_id,
    // data values
    input [31:0] rs1_data_id, rs2_data_id, imm_id,
    // need to hold for future stages
    input [31:0] pc_id, nxpc_id,

    // control signals
    //output branch_ex, jal_ex, jalr_ex,
    output mem_read_ex, mem_write_ex,
    output alu_src1_ex, alu_src2_ex,
    output reg_write_ex,
    output [1:0] reg_src_ex,
    output [2:0] instr_funct3_ex,
    output [3:0] alu_type_ex,
    output [4:0] rd_ex, rs1_ex, rs2_ex,
    // data values
    output [31:0] rs1_data_ex, rs2_data_ex, imm_ex,
    // need to hold for future stages
    output [31:0] pc_ex, nxpc_ex
);

    // PipeDff #(1) branch_dff(
    //     .clk(clk), .bubble(bubble), .stall(stall),
    //     .default_val(1'b0), .data_in(branch_id),
    //     .data_out(branch_ex)
    // );
    // PipeDff #(1) jal_dff(
    //     .clk(clk), .bubble(bubble), .stall(stall),
    //     .default_val(1'b0), .data_in(jal_id),
    //     .data_out(jal_ex)
    // );
    // PipeDff #(1) jalr_dff(
    //     .clk(clk), .bubble(bubble), .stall(stall),
    //     .default_val(1'b0), .data_in(jalr_id),
    //     .data_out(jalr_ex)
    // );
    PipeDff #(1) mem_read_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(mem_read_id),
        .data_out(mem_read_ex)
    );
    PipeDff #(1) mem_write_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(mem_write_id),
        .data_out(mem_write_ex)
    );
    PipeDff #(1) alu_src1_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(alu_src1_id),
        .data_out(alu_src1_ex)
    );
    PipeDff #(1) alu_src2_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(alu_src2_id),
        .data_out(alu_src2_ex)
    );
    PipeDff #(1) reg_write_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(1'b0), .data_in(reg_write_id),
        .data_out(reg_write_ex)
    );
    PipeDff #(2) reg_src_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(2'b00), .data_in(reg_src_id),
        .data_out(reg_src_ex)
    );
    PipeDff #(3) instr_funct3_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(3'b000), .data_in(instr_funct3_id),
        .data_out(instr_funct3_ex)
    );
    PipeDff #(4) alu_type_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(4'b0000), .data_in(alu_type_id),
        .data_out(alu_type_ex)
    );
    PipeDff #(5) rd_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(5'b00000), .data_in(rd_id),
        .data_out(rd_ex)
    );
    PipeDff #(5) rs1_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(5'b00000), .data_in(rs1_id),
        .data_out(rs1_ex)
    );
    PipeDff #(5) rs2_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(5'b00000), .data_in(rs2_id),
        .data_out(rs2_ex)
    );

    PipeDff #(32) rs1_data_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(rs1_data_id),
        .data_out(rs1_data_ex)
    );
    PipeDff #(32) rs2_data_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(rs2_data_id),
        .data_out(rs2_data_ex)
    );
    PipeDff #(32) imm_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(imm_id),
        .data_out(imm_ex)
    );
    
    PipeDff #(32) pc_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(pc_id),
        .data_out(pc_ex)
    );
    PipeDff #(32) nxpc_dff(
        .clk(clk), .bubble(bubble), .stall(stall),
        .default_val(`ZERO_WORD), .data_in(nxpc_id),
        .data_out(nxpc_ex)
    );

endmodule