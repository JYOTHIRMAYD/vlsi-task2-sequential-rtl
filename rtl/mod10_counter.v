`timescale 1ns/1ps
// Decade counter: 0..9 then back to 0. tc is high while q == 9.
module mod10_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    output reg  [3:0] q,
    output wire       tc
);
    assign tc = (q == 4'd9);
    always @(posedge clk or posedge reset) begin
        if (reset)   q <= 4'd0;
        else if (en) q <= tc ? 4'd0 : q + 4'd1;
    end
endmodule
