`timescale 1ns/1ps
// Parameterized up/down counter with modulus.
//   N    : width
//   MOD  : counts 0..MOD-1 (default 2**N = free-running binary counter)
//   up_down: 1 = count up, 0 = count down
//   clr  : synchronous clear
//   tc   : terminal count (MOD-1 when counting up, 0 when counting down)
module counter_n #(
    parameter N = 4,
    parameter MOD = (1 << N),
    parameter ASYNC_RESET = 1
)(
    input  wire         clk,
    input  wire         reset,
    input  wire         clr,
    input  wire         en,
    input  wire         up_down,
    output reg  [N-1:0] q,
    output wire         tc
);
    wire [N-1:0] last = MOD - 1;
    assign tc = up_down ? (q == last) : (q == {N{1'b0}});

    wire [N-1:0] q_next = up_down ? ((q == last) ? {N{1'b0}} : q + 1'b1)
                                  : ((q == {N{1'b0}}) ? last : q - 1'b1);
generate
    if (ASYNC_RESET) begin : g_async
        always @(posedge clk or posedge reset) begin
            if (reset)    q <= {N{1'b0}};
            else if (clr) q <= {N{1'b0}};
            else if (en)  q <= q_next;
        end
    end else begin : g_sync
        always @(posedge clk) begin
            if (reset)    q <= {N{1'b0}};
            else if (clr) q <= {N{1'b0}};
            else if (en)  q <= q_next;
        end
    end
endgenerate
endmodule
