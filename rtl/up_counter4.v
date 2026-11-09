`timescale 1ns/1ps
module up_counter4 (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    output reg  [3:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset)   q <= 4'd0;
        else if (en) q <= q + 4'd1;   // wraps 15 -> 0
    end
endmodule
