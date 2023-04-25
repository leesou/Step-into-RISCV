`include "src/defines.v"

module RAM (
    input clk, debug,
    input write_enable,
    input [2:0] write_type,
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
);

    integer out_file;
    parameter LEN = 65536;
    reg [31:0] mem_core [0:LEN-1];

    integer i, j;
    initial 
    begin
        for(i=1; i<=LEN; i+=1)
        begin
            mem_core[i-1] = 0; 
        end
        
        out_file = $fopen("ram.txt", "w");

        if(`TEST_TYPE==0)
        begin
            $readmemh("test_codes/0_test_load_store/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==1)
        begin
            $readmemh("test_codes/1_test_rtype/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==2)
        begin
            $readmemh("test_codes/2_test_itype/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==3)
        begin
            $readmemh("test_codes/3_test_btype/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==4)
        begin
            $readmemh("test_codes/4_test_utype/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==5)
        begin
            $readmemh("test_codes/5_test_jal/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==6)
        begin
            $readmemh("test_codes/6_test_jalr/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==7)
        begin
            $readmemh("test_codes/7_matmul/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==8)
        begin
            $readmemh("test_codes/8_quicksort/ram_data.hex", mem_core);
        end
    end

    wire [31:0] base_index = addr >> 2;
    wire [1:0] sb_offset = addr[1:0];
    wire sh_offset = addr[1];

    // write data to memory
    always @(posedge clk) 
    begin
        if(write_enable)
        begin
            if(write_type == `SB) 
            begin
                if(sb_offset==0)
                begin
                    mem_core[base_index][31:24] = data_in[7:0];
                end
                else if(sb_offset==1)
                begin
                    mem_core[base_index][23:16] = data_in[7:0];
                end
                else if(sb_offset==2)
                begin
                    mem_core[base_index][15:8] = data_in[7:0];
                end
                else if(sb_offset==3)
                begin
                    mem_core[base_index][7:0] = data_in[7:0];
                end
            end
            else if(write_type == `SH)
            begin
                if(sh_offset==0)
                begin
                    mem_core[base_index][31:16] = data_in[15:0];
                end
                else if(sh_offset==1)
                begin
                    mem_core[base_index][15:0] = data_in[15:0];
                end
            end
            else if(write_type == `SW)
            begin
                mem_core[base_index] <= data_in;
            end
            
        end    
    end

    // read data from memory
    assign data_out = mem_core[base_index];

    // output memory data for result verification
    integer ram_index = 0;
    always @(posedge clk) 
    begin
        if(debug)
        begin
            if(`TEST_TYPE == 0)
            begin
                for(i=0; i<=14; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 1)
            begin
                for(i=0; i<=14; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 2)
            begin
                for(i=0; i<=14; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 3)
            begin
                for(i=0; i<=7; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 4)
            begin
                for(i=0; i<=5; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 5)
            begin
                for(i=0; i<=5; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 6)
            begin
                for(i=0; i<=5; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE == 7)
            begin
                for(i=0; i<32; i+=1)
                begin
                    for(j=0; j<32; j+=1)
                    begin
                        $fwrite(out_file, "%8h ", mem_core[ram_index]);
                        ram_index = ram_index+1;
                    end
                    $fwrite(out_file, "\n");
                end
            end
            else if(`TEST_TYPE == 8)
            begin
                for(i=0; i<512; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
        end    
    end

endmodule