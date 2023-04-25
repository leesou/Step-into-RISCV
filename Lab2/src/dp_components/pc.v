module PC (
    input clk,
    input rst,
    input [31:0] pc_in,
    output reg [31:0] pc_out
);

    always @(posedge clk) 
    begin
        if(rst)
        begin
            pc_out <= 0;
        end    
        else
        begin
            pc_out <= pc_in;
        end
    end
    
endmodule