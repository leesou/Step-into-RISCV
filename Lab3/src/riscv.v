`include "src/five_stages/if.v"
`include "src/five_stages/id.v"
`include "src/five_stages/ex.v"
`include "src/five_stages/mem.v"
`include "src/five_stages/wb.v"

module RISCVSingleSycle (
    input clk, rst,
    input [31:0] instr, mem_read_data,
    output ram_write,
    output [2:0] write_type,
    output [31:0] instr_addr, mem_addr, mem_write_data
);

    wire pc_src, alu_src1, alu_src2, branch, jal, jalr, mem_read, mem_write;
    wire [1:0] reg_src;
    wire [2:0] branch_type, load_type, store_type;
    wire [3:0] alu_type;
    wire [31:0] pc, new_pc, nxpc, reg_write_data, rs1_data, rs2_data, imm, alu_result, mem_to_reg_data;

    InstructionFetch if_stage(
        .clk(clk), .rst(rst),
        .pc_src(pc_src),
        .pc_in(new_pc),
        .pc(pc), .nxpc(nxpc)
    );
    // instruction fetch is executed outside logic module
    assign instr_addr = pc;

    InstructionDecode id_stage(
        .clk(clk),
        .instr(instr),
        .reg_write_data(reg_write_data),
        .alu_src1(alu_src1), .alu_src2(alu_src2),
        .rs1_data(rs1_data), .rs2_data(rs2_data), .imm(imm),
        .alu_type(alu_type),
        .branch(branch), .jal(jal), .jalr(jalr), .mem_read(mem_read), .mem_write(mem_write),
        .reg_src(reg_src),
        .branch_type(branch_type), .load_type(load_type), .store_type(store_type)
    );

    Execute ex_stage(
        .branch(branch), .jal(jal), .jalr(jalr),
        .branch_type(branch_type),
        .alu_src1(alu_src1), .alu_src2(alu_src2),
        .alu_type(alu_type),
        .pc(pc), .rs1_data(rs1_data), .rs2_data(rs2_data), .imm(imm),
        .pc_src(pc_src),
        .alu_result(alu_result), .new_pc(new_pc)
    );
    
    // memory access stage is partially executed outside the logic module
    assign ram_write = mem_write;
    assign write_type = store_type;
    assign mem_write_data = rs2_data;
    assign mem_addr = alu_result;
    MemAccess mem_stage(
        .mem_read(mem_read),
        .load_type(load_type),
        .mem_read_data(mem_read_data),
        .mem_to_reg_data(mem_to_reg_data)
    );

    WriteBack wb_module(
        .reg_src(reg_src),
        .alu_result(alu_result), .mem_to_reg_data(mem_to_reg_data), .imm(imm), .nxpc(nxpc),
        .reg_write_data(reg_write_data)
    );
    
endmodule