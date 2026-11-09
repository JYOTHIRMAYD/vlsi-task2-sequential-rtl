`timescale 1ns/1ps
module down_counter4 (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    output reg  [3:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset)   q <= 4'd15;      // starts at max, counts down
        else if (en) q <= q - 4'd1;   // wraps 0 -> 15
    end
endmodule
