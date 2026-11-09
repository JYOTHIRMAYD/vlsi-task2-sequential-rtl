`timescale 1ns/1ps
// 8-bit register (Exercise 1) built from the parameterized register.
module register8 #(
    parameter ASYNC_RESET = 1
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       en,
    input  wire [7:0] d,
    output wire [7:0] q
);
    register_n #(.N(8), .ASYNC_RESET(ASYNC_RESET)) u_reg (
        .clk(clk), .reset(reset), .en(en), .d(d), .q(q)
    );
endmodule
