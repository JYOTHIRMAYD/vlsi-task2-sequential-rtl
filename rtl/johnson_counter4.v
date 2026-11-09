`timescale 1ns/1ps
// Twisted-ring counter, 8 states:
// 0000 0001 0011 0111 1111 1110 1100 1000 (repeat)
module johnson_counter4 (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    output reg  [3:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset)   q <= 4'b0000;
        else if (en) q <= {q[2:0], ~q[3]};
    end
endmodule
