module simple_memory (
    input clk,
    input        mem_valid,
    output reg   mem_ready,
    input [31:0] mem_addr,
    input [31:0] mem_wdata,
    input [3:0]  mem_wstrb,
    output reg [31:0] mem_rdata
);

    reg [31:0] memory [0:1023];

    // Increased delay for clearer cache effect
    reg [3:0] delay;   // supports up to 15 cycles delay

    always @(posedge clk) begin
        if (mem_valid) begin
            if (delay < 8) begin   // 🔥 increase latency here
                delay <= delay + 1;
                mem_ready <= 0;
            end else begin
                delay <= 0;
                mem_ready <= 1;

                if (mem_wstrb != 0) begin
                    // WRITE
                    memory[mem_addr >> 2] <= mem_wdata;
                end else begin
                    // READ
                    mem_rdata <= memory[mem_addr >> 2];
                end
            end
        end else begin
            mem_ready <= 0;
            delay <= 0;
        end
    end

endmodule