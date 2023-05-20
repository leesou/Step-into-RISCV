`include "src/defines.v"

module HazardDetectUnit (
    input rst,
    // for load use hazard
    input mem_read_ex,
    input [4:0] rd_ex,
    input [4:0] rs1_id, rs2_id,
    // for control hazard
    input pc_src_id, jal_id, jalr_id, branch_id,
    input mem_read_mem,
    input [4:0] rd_mem,
    // for memory access stall
    input cache_request_finish, mem_write_mem,
    output stall_if, stall_id, stall_ex, stall_mem, stall_wb,
    output bubble_if, bubble_id, bubble_ex, bubble_mem, bubble_wb
);

    // part 1: detect load use hazard to conduct pipeline stall
    // load-use hazard, is detected at ID-EX stage
    wire load_use_hazard = (mem_read_ex) ? (((rd_ex == rs1_id) || (rd_ex == rs2_id)) ? 1 : 0) : 0;

    // part 2: detect B-Type/jal/jalr instructions to conduct pipeline flush
    // by default, pc increments linearly (i.e., predict no branch)
    // Since we have push forward branch decision to ID stage,
    // we only need to bubble ID stage's execution when branch occurs
    wire control_hazard = jal_id ? pc_src_id :
                          jalr_id ? pc_src_id :
                          branch_id ? pc_src_id :
                          0;
    // for B-Type and jalr, if EX's rd is equal to ID's rs1/rs2, stall one cycle
    // note that data read from memory can only be forwarded at WB stage
    // note that ZERO REG SHOULD NOT be judging tatget!!!!!!
    wire branch_ex_hazard = (rd_ex != `ZERO_REG) && ((rd_ex == rs1_id) || (rd_ex == rs2_id));
    wire branch_mem_hazard = mem_read_mem && (rd_mem!=`ZERO_REG) && ((rd_mem == rs1_id) || (rd_mem == rs2_id));
    wire jalr_ex_hazard = (rd_ex != `ZERO_REG) && (rd_ex == rs1_id);
    wire jalr_mem_hazard = mem_read_mem && (rd_mem != `ZERO_REG) && (rd_mem == rs1_id);
    wire branch_forwarding_hazard = branch_id ? (branch_ex_hazard || branch_mem_hazard) :
                                    jalr_id ? (jalr_ex_hazard || jalr_mem_hazard) :
                                    0;

    assign stall_if = load_use_hazard ? 1 :
                      branch_forwarding_hazard ? 1 :
                      // (!cache_request_finish && (mem_read_mem || mem_write_mem)) ? 1 :
                      mem_read_mem ? ~cache_request_finish :
                      mem_write_mem ? ~cache_request_finish :
                      1'b0;
    assign stall_id = load_use_hazard ? 1 :
                      branch_forwarding_hazard ? 1 :
                      // (!cache_request_finish && (mem_read_mem || mem_write_mem)) ? 1 :
                      mem_read_mem ? ~cache_request_finish :
                      mem_write_mem ? ~cache_request_finish :
                      1'b0;
    assign stall_ex = mem_read_mem ? ~cache_request_finish :
                      mem_write_mem ? ~cache_request_finish :
                      // (!cache_request_finish && (mem_read_mem || mem_write_mem)) ? 1 :
                      1'b0;
    assign stall_mem = mem_read_mem ? ~cache_request_finish :
                      mem_write_mem ? ~cache_request_finish :
                      // (!cache_request_finish && (mem_read_mem || mem_write_mem)) ? 1 :
                      1'b0;
    assign stall_wb = mem_read_mem ? ~cache_request_finish :
                      mem_write_mem ? ~cache_request_finish :
                      // (!cache_request_finish && (mem_read_mem || mem_write_mem)) ? 1 :
                      1'b0;

    assign bubble_if = rst ? 1 : 0;
    assign bubble_id = rst ? 1 :
                       control_hazard ? !branch_forwarding_hazard :
                       0;
    assign bubble_ex = rst ? 1 :
                       load_use_hazard ? 1 :
                       branch_forwarding_hazard ? 1 : 
                       0;
    assign bubble_mem = rst ? 1 : 0;
    assign bubble_wb = rst ? 1 : 0;

endmodule