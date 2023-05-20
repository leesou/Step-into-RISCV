`include "src/defines.v"

module RAM #(
    parameter ADDR_LEN = 16
) (
    input clk, debug,
    input write_enable,
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
);

    integer out_file;
    parameter LEN = 1 << ADDR_LEN;
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
            $readmemh("test_codes/0_matmul/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==1)
        begin
            $readmemh("test_codes/1_quicksort/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==2)
        begin
            $readmemh("test_codes/2_matmul_flush/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==3)
        begin
            $readmemh("test_codes/3_quicksort_flush/ram_data.hex", mem_core);
        end
        else if(`TEST_TYPE==4)
        begin
            $readmemh("test_codes/4_naive_test/ram_data.hex", mem_core);
        end
    end

    // output memory data for result verification
    integer ram_index = 0;
    always @(posedge clk) 
    begin
        if(debug)
        begin
            if(`TEST_TYPE==0)
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
            else if(`TEST_TYPE==1)
            begin
                for(i=0; i<512; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE==2)
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
            else if(`TEST_TYPE==3)
            begin
                for(i=0; i<512; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
            else if(`TEST_TYPE==4)
            begin
                for(i=0; i<1024; i+=1)
                begin
                    $fwrite(out_file, "%8h\n", mem_core[i]);
                end
            end
        end    
    end





    // write data to memory
    always @(posedge clk) 
    begin
        if(write_enable)
        begin
            mem_core[addr[ADDR_LEN+1:2]] <= data_in;
        end    
    end

    // read data from memory
    assign data_out = mem_core[addr[ADDR_LEN+1:2]];



endmodule