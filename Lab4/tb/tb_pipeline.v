`timescale 1ns/1ns

// for verification
// you can change it to adjust which test code you want to run
`define TEST_TYPE 8

`include "src/riscv_top.v"

module TB_Pipeline;
    initial begin            
        $dumpfile("wave.vcd");  // generate wave.vcd
        $dumpvars(0, TB_Pipeline);   // dump all of the TB module data
    end

    reg clk;
    initial clk = 0;
    always #1 clk = ~clk;

    reg rst, debug;

    integer out_file;
    initial 
    begin
        #0
        rst = 1;
        debug = 0;
    
        #2
        rst = 0;

        // you can change this shorter when running code 0-6
        // for 7-8, since they have loop/recursion, we have to keep it long enough
        if(`TEST_TYPE <= 6)
        begin
            #1024
            debug = 1;
        end
        else if(`TEST_TYPE >= 7)
        begin
            #4194304
            debug = 1;
        end
        #2
        debug = 0;
        $stop;

    end

    RISCVTop riscv_top(
        .clk(clk), .rst(rst), .debug(debug)
    );

endmodule