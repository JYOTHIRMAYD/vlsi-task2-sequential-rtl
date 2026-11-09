`timescale 1ns/1ps
// N-bit serial-in shift register (shifts left: new bit enters at q[0]).
// Serial-in/serial-out uses serial_out; serial-in/parallel-out uses q.
module shift_register_n #(
    parameter N = 4,
    parameter ASYNC_RESET = 1
)(
    input  wire         clk,
    input  wire         reset,
    input  wire         shift_in,
    output reg  [N-1:0] q,
    output wire         serial_out
);
    assign serial_out = q[N-1];
generate
    if (ASYNC_RESET) begin : g_async
        always @(posedge clk or posedge reset) begin
            if (reset) q <= {N{1'b0}};
            else       q <= {q[N-2:0], shift_in};
        end
    end else begin : g_sync
        always @(posedge clk) begin
            if (reset) q <= {N{1'b0}};
            else       q <= {q[N-2:0], shift_in};
        end
    end
endgenerate
endmodule
