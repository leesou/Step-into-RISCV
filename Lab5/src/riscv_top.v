`include "src/riscv.v"
`include "src/rom.v"
// add main memory in Lab 5
`include "src/main_memory_wrapper.v"

module RISCVTop (
    input clk, rst, debug
);
    parameter LINE_ADDR_LEN = 3;
    
    // for instr rom
    wire [31:0] instr, instr_addr;
    // for main memory
    wire mem_read_request, mem_write_request, mem_request_finish;
    wire [31:0] mem_addr;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] mem_read_data ;
    wire [(32*(1<<LINE_ADDR_LEN)-1):0] mem_write_data ;

    RISCVPipeline #(.LINE_ADDR_LEN(LINE_ADDR_LEN)) riscv(
        .clk(clk), .rst(rst), .debug(debug),
        // for instr rom
        .instr(instr),
        .instr_addr(instr_addr),
        // for main memory
        .mem_read_request(mem_read_request), .mem_write_request(mem_write_request),
        .mem_write_data(mem_write_data),
        .mem_addr(mem_addr),
        .mem_request_finish(mem_request_finish),
        .mem_read_data(mem_read_data)
    );

    ROM instr_rom(
        .clk(clk),
        .addr(instr_addr),
        .data_out(instr)
    );

    MainMemoryWrapper #(.LINE_ADDR_LEN(LINE_ADDR_LEN)) main_memory(
        .clk(clk), .rst(rst), .debug(debug),
        .read_request(mem_read_request), .write_request(mem_write_request),
        .write_data(mem_write_data),
        .addr(mem_addr),
        .request_finish(mem_request_finish),
        .read_data(mem_read_data)
    );

endmodule