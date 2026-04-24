`timescale 1ns/1ps

module tb_nocache;

    reg clk = 0;
    reg reset = 1;

    always #5 clk = ~clk;

    top_nocache uut (
        .clk(clk),
        .reset(reset)
    );

    integer start_time, end_time;

    // ✅ Stall cycle counter
    reg [31:0] stall_cycles = 0;

    // Count stall cycles (CPU waiting for memory)
    always @(posedge clk) begin
        if (uut.mem_valid && !uut.mem_ready)
            stall_cycles <= stall_cycles + 1;
    end

    initial begin
        $dumpfile("nocache.vcd");
        $dumpvars(0, tb_nocache);

        #20 reset = 0;

        // Start timing AFTER reset
        start_time = $time;

        // Run simulation workload
        repeat (200) @(posedge clk);

        end_time = $time;

        // Results
        $display("\n--- NO CACHE ---");
        $display("Stall Cycles = %0d", stall_cycles);
        $display("Execution Time = %0d ns", end_time - start_time);

        $finish;
    end

endmodule