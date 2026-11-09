`timescale 1ns/1ps
// One-hot ring counter: 0001 -> 0010 -> 0100 -> 1000 -> 0001 ...
module ring_counter4 (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    output reg  [3:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset)   q <= 4'b0001;
        else if (en) q <= {q[2:0], q[3]};
    end
endmodule
