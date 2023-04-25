module Adder #(parameter WIDTH=32) (
    input [WIDTH-1:0] data_in1,
    input [WIDTH-1:0] data_in2,
    output [WIDTH-1:0] data_out
);
    
    assign data_out = data_in1+data_in2;

endmodule