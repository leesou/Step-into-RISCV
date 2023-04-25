`timescale 1ns/1ns
`include "src/top.v"
`include "src/defines.v"

module TB_ALU;
    initial begin            
        $dumpfile("wave.vcd");  // generate wave.vcd
        $dumpvars(0, TB_ALU);   // dump all of the TB module data
    end

    reg clk;
    initial clk = 0;
    always #1 clk = ~clk;

    reg write_enable;
    reg [31:0] addr;
    reg [31:0] data_in;
    reg [3:0] aluop;
    reg [31:0] data_in2;
    wire [31:0] data_out;

    integer out_file;
    initial 
    begin
        out_file = $fopen("./output.txt", "w");
        write_enable = 0;
        data_in = 0;

        #1 // test add
        addr = 0;
        aluop = `ADD;
        data_in2 = 32'h01234567;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test sub
        addr = 4;
        aluop = `SUB;
        data_in2 = 32'h01234567;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test sll
        addr = 8;
        aluop = `SLL;
        data_in2 = 32'h00000010;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test slt
        addr = 12;
        `aluop = `SLT;
        data_in2 = 32'h00000000;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test sltu
        addr = 16;
        aluop = `SLTU;
        data_in2 = 32'h00000000;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test xor
        addr = 20;
        aluop = `XOR;
        data_in2 = 32'hf0f0e0e0;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test srl
        addr = 24;
        aluop = SRL;
        data_in2 = 32'h00000010;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test sra
        addr = 28;
        aluop = `SRA;
        data_in2 = 32'h00000010;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test or
        addr = 32;
        aluop = `OR;
        data_in2 = 32'hffff0000;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2 // test and
        addr = 36;
        aluop = `AND;
        data_in2 = 32'hffff0000;
        #2
        $fwrite(out_file, "%8h\n", data_out);

        #2
        $stop;
    end

    TOP top_module(
        .clk(clk),
        .write_enable(write_enable),
        .addr(addr),
        .data_in(data_in),
        .aluop(aluop),
        .data_in2(data_in2),
        .dataout(data_out)
    );

endmodule