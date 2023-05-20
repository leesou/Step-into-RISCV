`include "src/defines.v"
`include "src/five_stages/if.v"
`include "src/five_stages/id.v"
`include "src/five_stages/ex.v"
`include "src/five_stages/mem.v"
`include "src/five_stages/wb.v"
`include "src/templates/pipe_dff.v"
`include "src/pipe_regs/if_id.v"
`include "src/pipe_regs/id_ex.v"
`include "src/pipe_regs/ex_mem.v"
`include "src/pipe_regs/mem_wb.v"
`include "src/hazard_unit/forward_unit_id.v"
`include "src/hazard_unit/forward_unit_ex.v"
`include "src/hazard_unit/stall_flush_detect_unit.v"
// add cache in Lab 5
`include "src/dp_components/data_cache.v"

module RISCVPipeline (
    input clk, rst, debug,
    // for instr rom
    input [31:0] instr,
    output [31:0] instr_addr,
    // for main memory
    output mem_read_request, mem_write_request,
    output [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data,
    output [31:0] mem_addr,
    input mem_request_finish,
    input [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data
);
    parameter LINE_ADDR_LEN = 3;

    // wires for if_id register
    wire [31:0] instr_if, pc_if, nxpc_if;
    wire [31:0] instr_id, pc_id, nxpc_id;

    // wires for id_ex register
    // wire branch_id, jal_id, jalr_id;
    wire mem_read_id, mem_write_id;
    wire alu_src1_id, alu_src2_id;
    wire reg_write_id;
    wire [1:0] reg_src_id;
    wire [2:0] instr_funct3_id;
    wire [3:0] alu_type_id;
    wire [4:0] rd_id, rs1_id, rs2_id;
    wire [31:0] rs1_data_id, rs2_data_id, imm_id;
    // wire branch_ex, jal_ex, jalr_ex;
    wire mem_read_ex, mem_write_ex;
    wire alu_src1_ex, alu_src2_ex;
    wire reg_write_ex;
    wire [1:0] reg_src_ex;
    wire [2:0] instr_funct3_ex;
    wire [3:0] alu_type_ex;
    wire [4:0] rd_ex, rs1_ex, rs2_ex;
    wire [31:0] rs1_data_ex, rs2_data_ex, imm_ex;
    wire [31:0] pc_ex, nxpc_ex;

    // wires for ex_mem register
    wire pc_src_ex;
    wire [31:0] new_pc_ex, alu_result_ex;
    wire pc_src_mem;
    wire [31:0] new_pc_mem, alu_result_mem;
    wire mem_read_mem, mem_write_mem, reg_write_mem;
    wire [1:0] reg_src_mem;
    wire [2:0] instr_funct3_mem;
    wire [4:0] rd_mem;
    wire [31:0] rs2_data_mem, imm_mem, nxpc_mem;

    // wires for mem_wb register
    wire [31:0] mem_to_reg_data_mem;
    wire [31:0] mem_to_reg_data_wb;
    wire reg_write_wb;
    wire [1:0] reg_src_wb;
    wire [4:0] rd_wb;
    wire [31:0] alu_result_wb, imm_wb, nxpc_wb;

    // wires for wb output
    wire [31:0] reg_write_data_wb;

    // wires for data hazard's bypassing
    wire [31:0] reg_write_data_mem; // mem stage's forwarding data
    wire [1:0] rs1_fwd_ex, rs2_fwd_ex;
    wire [31:0] rs2_data_real; // for data hazard with store instruction followed
    // wires for bubble/stall control
    wire bubble_if, bubble_id, bubble_ex, bubble_mem, bubble_wb;
    wire stall_if, stall_id, stall_ex, stall_mem, stall_wb;
    // wires for control hazard
    wire branch_id, jal_id, jalr_id;
    wire rs1_fwd_id, rs2_fwd_id;
    wire pc_src_id;
    wire [31:0] new_pc_id;

    // wires for cache connection
    wire cache_request_finish;
    wire [31:0] cache_read_data;

    InstructionFetch if_stage(
        .clk(clk), .rst(rst),
        .bubble(bubble_if), .stall(stall_if),
        .pc_src(pc_src_id),
        .pc_in(new_pc_id),
        .pc(pc_if), .nxpc(nxpc_if)
    );
    // instruction fetch is executed outside logic module
    assign instr_addr = pc_if;
    assign instr_if = instr;

    IFID if_id_reg(
        .clk(clk), .bubble(bubble_id), .stall(stall_id),
        .instr_if(instr_if), .pc_if(pc_if), .nxpc_if(nxpc_if),
        .instr_id(instr_id), .pc_id(pc_id), .nxpc_id(nxpc_id)
    );

    InstructionDecode id_stage(
        .clk(clk), .rst(rst),
        .instr(instr_id),
        .reg_write_in(reg_write_wb),
        .rd_in(rd_wb),
        .reg_write_data(reg_write_data_wb),
        .alu_src1(alu_src1_id), .alu_src2(alu_src2_id),
        .rs1_data(rs1_data_id), .rs2_data(rs2_data_id), .imm(imm_id),
        .alu_type(alu_type_id),
        .branch(branch_id), .jal(jal_id), .jalr(jalr_id),
        .mem_read(mem_read_id), .mem_write(mem_write_id),
        .reg_write_out(reg_write_id),
        .rd_out(rd_id), 
        .reg_src(reg_src_id),
        .instr_funct3(instr_funct3_id),
        // for data forwarding
        .rs1_out(rs1_id), .rs2_out(rs2_id),
        // for control hazard
        .pc(pc_id),
        .mem_fwd_data(reg_write_data_mem),
        .rs1_fwd(rs1_fwd_id), .rs2_fwd(rs2_fwd_id),
        .pc_src(pc_src_id),
        .new_pc(new_pc_id)
    );

    IDEX id_ex_reg(
        .clk(clk), .bubble(bubble_ex), .stall(stall_ex),

        // .branch_id(branch_id), .jal_id(jal_id), .jalr_id(jalr_id),
        .mem_read_id(mem_read_id), .mem_write_id(mem_write_id),
        .alu_src1_id(alu_src1_id), .alu_src2_id(alu_src2_id),
        .reg_write_id(reg_write_id),
        .reg_src_id(reg_src_id),
        .instr_funct3_id(instr_funct3_id),
        .alu_type_id(alu_type_id),
        .rd_id(rd_id), .rs1_id(rs1_id), .rs2_id(rs2_id),
        .rs1_data_id(rs1_data_id), .rs2_data_id(rs2_data_id), .imm_id(imm_id),
        .pc_id(pc_id), .nxpc_id(nxpc_id),

        // .branch_ex(branch_ex), .jal_ex(jal_ex), .jalr_ex(jalr_ex),
        .mem_read_ex(mem_read_ex), .mem_write_ex(mem_write_ex),
        .alu_src1_ex(alu_src1_ex), .alu_src2_ex(alu_src2_ex),
        .reg_write_ex(reg_write_ex),
        .reg_src_ex(reg_src_ex),
        .instr_funct3_ex(instr_funct3_ex),
        .alu_type_ex(alu_type_ex),
        .rd_ex(rd_ex), .rs1_ex(rs1_ex), .rs2_ex(rs2_ex),
        .rs1_data_ex(rs1_data_ex), .rs2_data_ex(rs2_data_ex), .imm_ex(imm_ex),
        .pc_ex(pc_ex), .nxpc_ex(nxpc_ex)
    );

    Execute ex_stage(
        // .branch(branch_ex), .jal(jal_ex), .jalr(jalr_ex),
        // .branch_type(instr_funct3_ex),
        .alu_src1(alu_src1_ex), .alu_src2(alu_src2_ex),
        .alu_type(alu_type_ex),
        .pc(pc_ex), .rs1_data(rs1_data_ex), .rs2_data(rs2_data_ex), .imm(imm_ex),
        // .pc_src(pc_src_ex),
        .alu_result(alu_result_ex), // .new_pc(new_pc_ex),
        // for data hazard
        .rs1_sel(rs1_fwd_ex), .rs2_sel(rs2_fwd_ex),
        .mem_fwd_data(reg_write_data_mem), .wb_fwd_data(reg_write_data_wb),
        .rs2_data_real(rs2_data_real)
    );

    EXMEM ex_mem_reg(
        .clk(clk), .bubble(bubble_mem), .stall(stall_mem),

        // .pc_src_ex(pc_src_ex),
        // .new_pc_ex(new_pc_ex),
        .alu_result_ex(alu_result_ex),
        .mem_read_ex(mem_read_ex), .mem_write_ex(mem_write_ex), .reg_write_ex(reg_write_ex),
        .reg_src_ex(reg_src_ex),
        .instr_funct3_ex(instr_funct3_ex),
        .rd_ex(rd_ex),
        .rs2_data_ex(rs2_data_real), .imm_ex(imm_ex), .nxpc_ex(nxpc_ex),

        // .pc_src_mem(pc_src_mem),
        // .new_pc_mem(new_pc_mem),
        .alu_result_mem(alu_result_mem),
        .mem_read_mem(mem_read_mem), .mem_write_mem(mem_write_mem), .reg_write_mem(reg_write_mem),
        .reg_src_mem(reg_src_mem),
        .instr_funct3_mem(instr_funct3_mem),
        .rd_mem(rd_mem),
        .rs2_data_mem(rs2_data_mem), .imm_mem(imm_mem), .nxpc_mem(nxpc_mem)
    );
    
    // memory access stage is partially executed outside the logic module
    DataCache #(.LINE_ADDR_LEN(LINE_ADDR_LEN)) data_cache(
        // cpu ports
        .clk(clk), .rst(rst), .debug(debug),
        .read_request(mem_read_mem), .write_request(mem_write_mem),
        .write_type(instr_funct3_mem),
        .addr(alu_result_mem), 
        .write_data(rs2_data_mem),
        .request_finish(cache_request_finish), .read_data(cache_read_data),
        // mem ports
        .mem_read_request(mem_read_request), .mem_write_request(mem_write_request),
        .mem_write_data(mem_write_data),
        .mem_addr(mem_addr),
        .mem_request_finish(mem_request_finish),
        .mem_read_data(mem_read_data)
    );
    MemAccess mem_stage(
        .mem_read(mem_read_mem),
        .load_type(instr_funct3_mem),
        .mem_read_data(cache_read_data),
        .mem_to_reg_data(mem_to_reg_data_mem)
    );
    // bypassing data selection
    // note that memory data cannot be accessed at bypassing's point
    assign reg_write_data_mem = (reg_src_mem == `FROM_ALU) ? alu_result_mem :
                                (reg_src_mem == `FROM_IMM) ? imm_mem :
                                (reg_src_mem == `FROM_PC) ? nxpc_mem :
                                32'h00000000;

    MEMWB mem_wb_reg(
        .clk(clk), .bubble(bubble_wb), .stall(stall_wb),
        
        .mem_to_reg_data_mem(mem_to_reg_data_mem),
        .reg_write_mem(reg_write_mem),
        .reg_src_mem(reg_src_mem),
        .rd_mem(rd_mem),
        .alu_result_mem(alu_result_mem), .imm_mem(imm_mem), .nxpc_mem(nxpc_mem),

        .mem_to_reg_data_wb(mem_to_reg_data_wb),
        .reg_write_wb(reg_write_wb),
        .reg_src_wb(reg_src_wb),
        .rd_wb(rd_wb),
        .alu_result_wb(alu_result_wb), .imm_wb(imm_wb), .nxpc_wb(nxpc_wb)
    );

    WriteBack wb_stage(
        .reg_src(reg_src_wb),
        .alu_result(alu_result_wb), .mem_to_reg_data(mem_to_reg_data_wb),
        .imm(imm_wb), .nxpc(nxpc_wb),
        .reg_write_data(reg_write_data_wb)
    );





    // hazard handling units
    ForwardUnitID forward_unit_id(
        .branch_id(branch_id), .jal_id(jal_id), .jalr_id(jalr_id),
        .reg_write_mem(reg_write_mem),
        .rd_mem(rd_mem), .rs1_id(rs1_id), .rs2_id(rs2_id),
        .rs1_fwd(rs1_fwd_id), .rs2_fwd(rs2_fwd_id)
    );

    FowardUnitEX forward_unit_ex(
        .reg_write_mem(reg_write_mem), .reg_write_wb(reg_write_wb),
        .rd_mem(rd_mem), .rd_wb(rd_wb),
        .rs1_ex(rs1_ex), .rs2_ex(rs2_ex),
        .rs1_fwd(rs1_fwd_ex), .rs2_fwd(rs2_fwd_ex)
    );

    HazardDetectUnit hazard_detect_unit(
        .rst(rst),
        // for load use hazard
        .mem_read_ex(mem_read_ex),
        .rd_ex(rd_ex),
        .rs1_id(rs1_id), .rs2_id(rs2_id),
        // for control hazard
        .pc_src_id(pc_src_id), .jal_id(jal_id), .jalr_id(jalr_id), .branch_id(branch_id),
        .rd_mem(rd_mem),
        .mem_read_mem(mem_read_mem),
        // for memory access stall
        .cache_request_finish(cache_request_finish), .mem_write_mem(mem_write_mem),
        .stall_if(stall_if), .stall_id(stall_id), .stall_ex(stall_ex), .stall_mem(stall_mem), .stall_wb(stall_wb),
        .bubble_if(bubble_if), .bubble_id(bubble_id), .bubble_ex(bubble_ex), .bubble_mem(bubble_mem), .bubble_wb(bubble_wb)
    );

    
endmodule