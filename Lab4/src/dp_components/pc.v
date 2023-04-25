`include "src/defines.v"

module PC (
    input clk, rst,
    input bubble, stall,
    input [31:0] pc_in,
    output [31:0] pc_out
);

    reg [31:0] pc_out_reg;
    wire [31:0] pc_out_wire;

    always @(posedge clk) 
    begin
        if(rst)
        begin
            pc_out_reg <= `PC_RST;
        end 
        else if(bubble)
        begin
            pc_out_reg <= pc_out_wire;
        end
        else if(stall)
        begin
            pc_out_reg <= pc_out_wire;
        end
        else
        begin
            pc_out_reg <= pc_in;
        end
    end

    assign pc_out_wire = pc_out_reg;
    assign pc_out = pc_out_wire;
    
endmodule