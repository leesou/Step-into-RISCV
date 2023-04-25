module PipeDff #( parameter WIDTH = 32) (
    input clk, bubble, stall,
    input [WIDTH-1:0] default_val, data_in,
    output [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] data_reg;
    wire [WIDTH-1:0] data_out_wire;

    always @(posedge clk) 
    begin   
        if(stall)
        begin
            data_reg <= data_out_wire;
        end
        else if(bubble)
        begin
            data_reg <= default_val;
        end 
        else
        begin
            data_reg <= data_in;
        end
    end

    assign data_out_wire = data_reg;
    assign data_out = data_out_wire;
    
endmodule