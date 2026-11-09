`timescale 1ns/1ps
// D flip-flop with selectable reset style.
// ASYNC_RESET = 1 : asynchronous active-high reset (matches the starter code)
// ASYNC_RESET = 0 : synchronous active-high reset
module d_flip_flop #(
    parameter ASYNC_RESET = 1
)(
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);
generate
    if (ASYNC_RESET) begin : g_async
        always @(posedge clk or posedge reset) begin
            if (reset) q <= 1'b0;
            else       q <= d;
        end
    end else begin : g_sync
        always @(posedge clk) begin
            if (reset) q <= 1'b0;
            else       q <= d;
        end
    end
endgenerate
endmodule
