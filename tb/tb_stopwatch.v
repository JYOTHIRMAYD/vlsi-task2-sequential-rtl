`timescale 1ns/1ps
// Stopwatch test with CLK_PER_TICK = 4 so one "second" = 4 clock cycles.
module tb_stopwatch;
    localparam CPT = 4;
    reg clk = 0, reset = 1, start_stop = 0, clear = 0;
    wire [5:0] sec, min;
    wire running;
    integer errors = 0;
    reg [5:0] s_hold;

    stopwatch_controller #(.CLK_PER_TICK(CPT), .TICK_W(8)) dut (
        .clk(clk), .reset(reset), .start_stop(start_stop), .clear(clear),
        .seconds(sec), .minutes(min), .running(running));

    always #5 clk = ~clk;

    task press;      // one-cycle button press
        begin
            start_stop = 1;
            @(posedge clk); #1;
            start_stop = 0;
        end
    endtask

    task chk;
        input [5:0] got, exp;
        input [8*12:1] tag;
        begin
            if (got !== exp) begin
                $display("ERROR: %0s got=%0d exp=%0d t=%0t", tag, got, exp, $time);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_stopwatch.vcd");
        $dumpvars(0, tb_stopwatch);
        repeat (3) @(posedge clk);
        #1 reset = 0;
        chk(sec, 0, "sec reset"); chk(min, 0, "min reset"); chk({5'b0, running}, 0, "idle");

        // start, run 3 seconds
        press;
        repeat (CPT*3 + 2) @(posedge clk); #1;
        chk(sec, 3, "3 seconds");
        chk({5'b0, running}, 1, "running");

        // pause: time must freeze
        press;
        repeat (2) @(posedge clk); #1;
        s_hold = sec;
        repeat (20) @(posedge clk); #1;
        chk(sec, s_hold, "paused");
        chk({5'b0, running}, 0, "not running");

        // resume: at least 2 more seconds after 9 cycles
        press;
        repeat (9) @(posedge clk); #1;
        if (sec < s_hold + 2) begin
            $display("ERROR: resume did not count (sec=%0d hold=%0d)", sec, s_hold);
            errors = errors + 1;
        end

        // pause then clear
        press;
        repeat (2) @(posedge clk); #1;
        clear = 1; @(posedge clk); #1 clear = 0;
        repeat (2) @(posedge clk); #1;
        chk(sec, 0, "clear sec"); chk(min, 0, "clear min");

        // run 60 seconds -> minutes = 1, seconds = 0
        press;
        repeat (CPT*60 + 2) @(posedge clk); #1;
        chk(min, 1, "minute"); chk(sec, 0, "sec wrap");

        if (errors == 0) $display("RESULT: PASS tb_stopwatch");
        else             $display("RESULT: FAIL tb_stopwatch (%0d errors)", errors);
        $finish;
    end
endmodule
