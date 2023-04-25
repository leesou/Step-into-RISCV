`include "src/defines.v"

module ROM (
    input clk,
    input [31:0] addr,
    output [31:0] data_out
);
    parameter LEN = 65536;
    reg [31:0] mem_core [0:LEN-1];

    integer i;
    initial 
    begin
        for(i=1; i<=LEN; i+=1)
        begin
            mem_core[i-1] = 0; 
        end

        if(`TEST_TYPE==0)
        begin
            $readmemh("test_codes/0_test_load_store/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==1)
        begin
            $readmemh("test_codes/1_test_rtype/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==2)
        begin
            $readmemh("test_codes/2_test_itype/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==3)
        begin
            $readmemh("test_codes/3_test_btype/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==4)
        begin
            $readmemh("test_codes/4_test_utype/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==5)
        begin
            $readmemh("test_codes/5_test_jal/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==6)
        begin
            $readmemh("test_codes/6_test_jalr/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==7)
        begin
            $readmemh("test_codes/7_matmul/rom_data.hex", mem_core);
        end
        else if(`TEST_TYPE==8)
        begin
            $readmemh("test_codes/8_quicksort/rom_data.hex", mem_core);
        end
    end

    assign data_out = mem_core[addr>>2];

endmodule