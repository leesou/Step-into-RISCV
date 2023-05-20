`include "src/defines.v"

module WriteBack (
    input [1:0] reg_src,
    input [31:0] alu_result, mem_to_reg_data, imm, nxpc,
    output [31:0] reg_write_data
);
    
    assign reg_write_data = (reg_src == `FROM_ALU) ? alu_result :
                            (reg_src == `FROM_MEM) ? mem_to_reg_data :
                            (reg_src == `FROM_IMM) ? imm :
                            (reg_src == `FROM_PC) ? nxpc :
                            32'h00000000;

endmodule