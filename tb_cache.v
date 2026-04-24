`timescale 1ns/1ps

module tb_cache;

    reg clk = 0;
    reg reset = 1;

    always #5 clk = ~clk;

    top uut (
        .clk(clk),
        .reset(reset)
    );

    integer i;

    initial begin
        $dumpfile("cache.vcd");
        $dumpvars(0, tb_cache);

        #20 reset = 0;

        // ==============================
        // TEST 1: SEQUENTIAL ACCESS
        // ==============================
        $display("\n===== TEST 1: SEQUENTIAL ACCESS =====");

        for (i = 0; i < 10; i = i + 1) begin
            uut.cpu.mem_valid = 1;
            uut.cpu.mem_addr  = i * 4;
            uut.cpu.mem_wstrb = 0;

            wait (uut.cpu.mem_ready);
            #10;
        end

        // Print results
        $display("Sequential Hit Rate = %f",
            (uut.cache.hit_count * 1.0) / uut.cache.total_access);
        $display("Sequential Stall Cycles = %0d",
            uut.cache.stall_cycles);

        // ==============================
        // RESET COUNTERS
        // ==============================
        uut.cache.hit_count = 0;
        uut.cache.miss_count = 0;
        uut.cache.total_access = 0;
        uut.cache.stall_cycles = 0;

        // ==============================
        // TEST 2: REPEATED ACCESS
        // ==============================
        $display("\n===== TEST 2: REPEATED ACCESS =====");

        for (i = 0; i < 10; i = i + 1) begin
            uut.cpu.mem_valid = 1;
            uut.cpu.mem_addr  = 32'h00000010;
            uut.cpu.mem_wstrb = 0;

            wait (uut.cpu.mem_ready);
            #10;
        end

        // Print results
        $display("Repeated Hit Rate = %f",
            (uut.cache.hit_count * 1.0) / uut.cache.total_access);
        $display("Repeated Stall Cycles = %0d",
            uut.cache.stall_cycles);

        $finish;
    end

endmodule