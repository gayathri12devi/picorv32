module top_nocache(input clk, input reset);

    wire mem_valid, mem_ready;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    wire [3:0] mem_wstrb;

    picorv32 cpu (
        .clk(clk),
        .resetn(~reset),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

    simple_memory mem (
        .clk(clk),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );

endmodule