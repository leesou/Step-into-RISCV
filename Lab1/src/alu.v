`include "src-lc/defines.v"

module ALU (
    input [3:0] aluop
    input [31:0] data_in1,
    input [31:0] data_in2,
    output [31:0] data_out
);

    assign dataout = (aluop == `ADD) ?  data_in1 + data_in2 :
                     (aluop == `SLL) ? data_in1 << data_in2 :
                     (aluop == `SLT) ? ($signed(data_in1)<$signed(data_in2) ? 1 : 0) :
                     (aluop == `SLTU) ? (data_in1<data_in2 ? 1 : 0) :
                     (aluop == `XOR) ? data_in1 ^ data_in2 :
                     (aluop == `SRL) ? data_in1 >> data_in2 :
                     (aluop == `OR) ? data_in1 | data_in2 :
                     (aluop == `AND) ? data_in1 & data_in2 :
                     (aluop == `SUB) ? data_in1 - data_in2 :
                     (aluop == `SRA) ? $signed($signed(data_in1) >>> data_in2) :
                     32'h00000000;
endmodule