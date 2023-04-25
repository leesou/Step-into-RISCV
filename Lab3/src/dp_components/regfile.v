module RegFile (
    input clk,
    input write_enable,
    input [4:0] read_addr1, read_addr2, write_addr,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);
    reg [31:0] register_file [0:31];
    integer i;
    initial
    begin
        for(i=1; i<=32; i+=1) begin
            register_file[i-1] = 0;
        end    
    end

    // write register
    always @(posedge clk) 
    begin
        if(write_enable)
        begin
            register_file[write_addr] <= write_data;
        end
    end

    // read register
    assign read_data1 = (read_addr1!=0) ? register_file[read_addr1] : 0;
    assign read_data2 = (read_addr2!=0) ? register_file[read_addr2] : 0;

endmodule