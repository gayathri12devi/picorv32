module top(input clk, input reset);

    wire mem_valid, mem_ready;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    wire [3:0] mem_wstrb;

    wire mem_valid_c, mem_ready_c;
    wire [31:0] mem_addr_c, mem_wdata_c, mem_rdata_c;
    wire [3:0] mem_wstrb_c;

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

    direct_mapped_cache cache (
        .clk(clk), .reset(reset),

        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        .mem_valid_out(mem_valid_c),
        .mem_ready_out(mem_ready_c),
        .mem_addr_out(mem_addr_c),
        .mem_wdata_out(mem_wdata_c),
        .mem_wstrb_out(mem_wstrb_c),
        .mem_rdata_out(mem_rdata_c)
    );

    simple_memory mem (
        .clk(clk),
        .mem_valid(mem_valid_c),
        .mem_ready(mem_ready_c),
        .mem_addr(mem_addr_c),
        .mem_wdata(mem_wdata_c),
        .mem_wstrb(mem_wstrb_c),
        .mem_rdata(mem_rdata_c)
    );

endmodule