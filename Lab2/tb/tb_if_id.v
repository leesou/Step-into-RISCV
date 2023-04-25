`timescale 1ns/1ns

`include "src/top.v"

module TB_IFID;
    initial begin            
        $dumpfile("wave.vcd");  // generate wave.vcd
        $dumpvars(0, TB_IFID);   // dump all of the TB module data
    end

    reg clk;
    initial clk = 0;
    always #1 clk = ~clk;

    reg rst;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;
    wire branch, jump, mem_read, mem_to_reg, mem_write, alu_src;
    wire [3:0] alu_type;
    wire reg_write_enable; wire [31:0] instr_out;

    integer out_file;
    initial 
    begin
        #0
        rst = 1;
        write_data = 32'h00000000;
        out_file = $fopen("output.txt", "w");
        
        #2
        rst = 0;
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $fwrite(out_file, "%8h %2d %2d %1d %1d %1d %1d %1d %1d %4b %1d\n",
            instr_out, read_data1, read_data2, branch, jump, mem_read, mem_to_reg, mem_write, alu_src, alu_type, reg_write_enable);
        #2
        $stop;
    end

    TOP top_module(
        .clk(clk), .rst(rst),
        .write_data(write_data),
        .read_data1(read_data1), .read_data2(read_data2),
        .branch(branch), .jump(jump),
        .mem_read(mem_read), .mem_to_reg(mem_to_reg), .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_type(alu_type),
        .reg_write_enable(reg_write_enable),
        .instr_out(instr_out)
    );

    
endmodule