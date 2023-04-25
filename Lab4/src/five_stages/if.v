`include "src/dp_components/pc.v"
//`include "src/rom.v"

module InstructionFetch (
    input clk, rst,
    input bubble, stall,
    input pc_src, // sent from pc_ex module
    input [31:0] pc_in, // sent from pc_ex module
    output [31:0] pc, nxpc//, instr
);
    wire[31:0] pc_plus4, pc_reg_in;
    wire[31:0] Imm4 = 32'h00000004;

    PC pc_reg(
        .clk(clk), .rst(rst), 
        .bubble(bubble), .stall(stall),
        .pc_in(pc_reg_in), .pc_out(pc)
    );
    assign pc_plus4 = $signed($signed(pc) + $signed(Imm4));
    //ROM rom(.clk(clk), .addr(pc), .data_out(instr));
    assign nxpc = pc_plus4;

    // PC update
    assign pc_reg_in = pc_src ? pc_in : pc_plus4;
    
endmodule