`timescale 1ns/1ps
// Compares async vs sync reset D flip-flop. Reset is asserted MID-cycle so
// the difference is visible in the waveform.
module tb_d_flip_flop;
    reg clk = 0, reset = 0, d = 0;
    wire q_async, q_sync;
    integer errors = 0;

    d_flip_flop #(.ASYNC_RESET(1)) u_async (.clk(clk), .reset(reset), .d(d), .q(q_async));
    d_flip_flop #(.ASYNC_RESET(0)) u_sync  (.clk(clk), .reset(reset), .d(d), .q(q_sync));

    always #5 clk = ~clk;

    task chk;
        input got, exp;
        input [8*12:1] tag;
        begin
            if (got !== exp) begin
                $display("ERROR: %0s got=%b exp=%b t=%0t", tag, got, exp, $time);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_d_flip_flop.vcd");
        $dumpvars(0, tb_d_flip_flop);

        #2 reset = 1;                 // mid-cycle, before first clock edge
        #1 chk(q_async, 1'b0, "async rst");
        @(posedge clk); #1;
        chk(q_async, 1'b0, "async rst2");
        chk(q_sync,  1'b0, "sync rst");
        reset = 0; d = 1;
        @(posedge clk); #1;
        chk(q_async, 1'b1, "load 1 a");
        chk(q_sync,  1'b1, "load 1 s");
        d = 0;
        @(posedge clk); #1;
        chk(q_async, 1'b0, "load 0 a");
        chk(q_sync,  1'b0, "load 0 s");
        d = 1;
        @(posedge clk); #1;
        // assert reset away from the clock edge
        #1 reset = 1;
        #1 chk(q_async, 1'b0, "async mid");   // clears immediately
        chk(q_sync,  1'b1, "sync hold");      // still waiting for clk edge
        @(posedge clk); #1;
        chk(q_sync,  1'b0, "sync clr");
        reset = 0;
        #20;
        if (errors == 0) $display("RESULT: PASS tb_d_flip_flop");
        else             $display("RESULT: FAIL tb_d_flip_flop (%0d errors)", errors);
        $finish;
    end
endmodule
