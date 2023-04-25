`include "src/defines.v"

module ALU (
    input [3:0] alu_type,
    input [31:0] data_in1,
    input [31:0] data_in2,
    output [31:0] data_out,
    output zero, less_than // for pc_ex module
);

    wire [31:0] sub_result = /*$signed($signed(data_in1) - $signed(data_in2))*/ data_in1 - data_in2;
    wire [31:0] slt_result = ($signed(data_in1)<$signed(data_in2) ? 1 : 0);
    wire [31:0] sltu_result = (data_in1<data_in2 ? 1 : 0);

    assign data_out = (alu_type == `ADD) ?  /*$signed($signed(data_in1) + $signed(data_in2))*/ data_in1 + data_in2 :
                     (alu_type == `SLL) ? data_in1 << data_in2 :
                     (alu_type == `SLT) ? slt_result :
                     (alu_type == `SLTU) ? sltu_result :
                     (alu_type == `XOR) ? data_in1 ^ data_in2 :
                     (alu_type == `SRL) ? data_in1 >> data_in2 :
                     (alu_type == `OR) ? data_in1 | data_in2 :
                     (alu_type == `AND) ? data_in1 & data_in2 :
                     (alu_type == `SUB) ? sub_result :
                     (alu_type == `SRA) ? $signed($signed(data_in1) >>> data_in2) :
                     32'h00000000;
    assign zero = (sub_result==0) ? 1 : 0;
    assign less_than = (alu_type==`SLT) ? slt_result[0] :
                       (alu_type==`SLTU) ? sltu_result[0] :
                       0;
endmodule