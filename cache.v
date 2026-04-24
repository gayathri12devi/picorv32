module direct_mapped_cache (
    input clk,
    input reset,

    input         mem_valid,
    output reg    mem_ready,
    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input  [3:0]  mem_wstrb,
    output reg [31:0] mem_rdata,

    output reg        mem_valid_out,
    input             mem_ready_out,
    output reg [31:0] mem_addr_out,
    output reg [31:0] mem_wdata_out,
    output reg [3:0]  mem_wstrb_out,
    input  [31:0]     mem_rdata_out
);

    parameter LINES = 16;
    parameter INDEX_BITS = 4;
    parameter TAG_BITS = 32 - INDEX_BITS - 2;

    reg [31:0] data_array [0:LINES-1];
    reg [TAG_BITS-1:0] tag_array [0:LINES-1];
    reg valid_array [0:LINES-1];

    reg [31:0] hit_count, miss_count, total_access;
    reg [31:0] stall_cycles; 

    wire [INDEX_BITS-1:0] index = mem_addr[INDEX_BITS+1:2];
    wire [TAG_BITS-1:0] tag   = mem_addr[31:INDEX_BITS+2];

    wire hit = valid_array[index] && (tag_array[index] == tag);

    reg state;
    localparam IDLE=0, MISS=1;

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_ready <= 0;
            mem_valid_out <= 0;
            state <= IDLE;

            hit_count <= 0;
            miss_count <= 0;
            total_access <= 0;
            stall_cycles <= 0;

            for (i=0;i<LINES;i=i+1)
                valid_array[i] <= 0;

        end else begin
            mem_ready <= 0;

            if (state == MISS && !mem_ready_out)
                stall_cycles <= stall_cycles + 1;

            case(state)

            IDLE: begin
                if (mem_valid) begin

                    if (mem_wstrb != 0) begin
                        // write-through
                        mem_valid_out <= 1;
                        mem_addr_out  <= mem_addr;
                        mem_wdata_out <= mem_wdata;
                        mem_wstrb_out <= mem_wstrb;

                        if (mem_ready_out) begin
                            mem_ready <= 1;
                            mem_valid_out <= 0;
                        end
                    end else begin
                        // READ
                        total_access <= total_access + 1;

                        if (hit) begin
                            hit_count <= hit_count + 1;
                            mem_rdata <= data_array[index];
                            mem_ready <= 1;
                            $display("CACHE HIT: %h", mem_addr);
                        end else begin
                            miss_count <= miss_count + 1;
                            $display("CACHE MISS: %h", mem_addr);

                            mem_valid_out <= 1;
                            mem_addr_out  <= mem_addr;
                            mem_wstrb_out <= 0;
                            state <= MISS;
                        end
                    end
                end
            end

            MISS: begin
                if (mem_ready_out) begin
                    mem_valid_out <= 0;

                    data_array[index] <= mem_rdata_out;
                    tag_array[index]  <= tag;
                    valid_array[index] <= 1;

                    mem_rdata <= mem_rdata_out;
                    mem_ready <= 1;

                    state <= IDLE;
                end
            end

            endcase
        end
    end

endmodule