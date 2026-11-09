`timescale 1ns/1ps
// Parameterized N-bit register with enable (Part C, Exercise 3).
module register_n #(
    parameter N = 8,
    parameter ASYNC_RESET = 1
)(
    input  wire         clk,
    input  wire         reset,
    input  wire         en,
    input  wire [N-1:0] d,
    output reg  [N-1:0] q
);
generate
    if (ASYNC_RESET) begin : g_async
        always @(posedge clk or posedge reset) begin
            if (reset)   q <= {N{1'b0}};
            else if (en) q <= d;
        end
    end else begin : g_sync
        always @(posedge clk) begin
            if (reset)   q <= {N{1'b0}};
            else if (en) q <= d;
        end
    end
endgenerate
endmodule
