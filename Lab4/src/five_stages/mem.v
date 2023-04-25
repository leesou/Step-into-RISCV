`include "src/defines.v"

module MemAccess (
    input mem_read,
    input [2:0] load_type,
    input [31:0] mem_read_data,
    output [31:0] mem_to_reg_data
);

    wire [31:0] offseted_mem_data = (load_type == `LB) ? {{24{mem_read_data[7]}}, mem_read_data[7:0]} :
                               (load_type == `LH) ? {{16{mem_read_data[15]}}, mem_read_data[15:0]} :
                               (load_type == `LW) ? mem_read_data :
                               (load_type == `LBU) ? {24'h000000, mem_read_data[7:0]} :
                               (load_type == `LHU) ? {16'h0000, mem_read_data[15:0]} :
                               32'h00000000 ;
    assign mem_to_reg_data = mem_read ? offseted_mem_data : 0;
    
endmodule