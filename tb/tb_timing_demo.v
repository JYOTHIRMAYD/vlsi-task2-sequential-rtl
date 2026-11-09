`timescale 1ns/100ps
// Exercise 5: setup/hold demonstration with a behavioral timing-check model.
// (Non-synthesizable, simulation only.) Clock period 10 ns, rising edges at
// 5, 15, 25 ... T_SETUP = 2 ns, T_HOLD = 1 ns.
module dff_timing_model #(
    parameter real T_SETUP = 2.0,
    parameter real T_HOLD  = 1.0
)(
    input  wire clk,
    input  wire d,
    output reg  q
);
    realtime t_d_change = -1000.0;
    realtime t_clk_edge = -1000.0;
    integer  setup_count = 0;
    integer  hold_count  = 0;

    initial q = 1'b0;

    always @(d) begin
        t_d_change = $realtime;
        if (($realtime - t_clk_edge) < T_HOLD) begin
            hold_count = hold_count + 1;
            $display("HOLD VIOLATION  at %0t ns: d changed %0.1f ns after clk edge", $realtime, $realtime - t_clk_edge);
            q <= 1'bx;
        end
    end

    always @(posedge clk) begin
        t_clk_edge = $realtime;
        if (($realtime - t_d_change) < T_SETUP) begin
            setup_count = setup_count + 1;
            $display("SETUP VIOLATION at %0t ns: d changed %0.1f ns before clk edge", $realtime, $realtime - t_d_change);
            q <= 1'bx;
        end else begin
            q <= d;
        end
    end
endmodule

module tb_timing_demo;
    reg clk = 0, d = 0;
    wire q;
    integer errors = 0;

    dff_timing_model dut (.clk(clk), .d(d), .q(q));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_timing_demo.vcd");
        $dumpvars(0, tb_timing_demo);
        #12 d = 1;                               // t=12: 3 ns before edge -> OK
        #4  if (q !== 1'b1) begin $display("ERROR: good setup, q=%b", q); errors = errors + 1; end
        #8  d = 0;                               // t=24: 1 ns before edge -> SETUP violation
        #2  if (q !== 1'bx) begin $display("ERROR: setup viol should give x, q=%b", q); errors = errors + 1; end
        #6  d = 1;                               // t=32: OK
        #3.5 d = 0;                              // t=35.5: 0.5 ns after edge -> HOLD violation
        #10.5 if (q !== 1'b0) begin $display("ERROR: recovery, q=%b", q); errors = errors + 1; end
        if (dut.setup_count !== 1 || dut.hold_count !== 1) begin
            $display("ERROR: expected 1 setup + 1 hold violation, got %0d / %0d", dut.setup_count, dut.hold_count);
            errors = errors + 1;
        end
        if (errors == 0) $display("RESULT: PASS tb_timing_demo");
        else             $display("RESULT: FAIL tb_timing_demo (%0d errors)", errors);
        $finish;
    end
endmodule
