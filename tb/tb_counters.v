`timescale 1ns/1ps
module tb_counters;
    reg clk = 0, reset = 1, en = 1;
    wire [3:0] up, down, mod10, ring, johnson;
    wire tc10;
    integer errors = 0;
    integer i;

    up_counter4      u_up   (.clk(clk), .reset(reset), .en(en), .q(up));
    down_counter4    u_down (.clk(clk), .reset(reset), .en(en), .q(down));
    mod10_counter    u_m10  (.clk(clk), .reset(reset), .en(en), .q(mod10), .tc(tc10));
    ring_counter4    u_ring (.clk(clk), .reset(reset), .en(en), .q(ring));
    johnson_counter4 u_jc   (.clk(clk), .reset(reset), .en(en), .q(johnson));

    always #5 clk = ~clk;

    function [3:0] jexp;
        input integer k;
        begin
            case (k % 8)
                0: jexp = 4'b0000;
                1: jexp = 4'b0001;
                2: jexp = 4'b0011;
                3: jexp = 4'b0111;
                4: jexp = 4'b1111;
                5: jexp = 4'b1110;
                6: jexp = 4'b1100;
                default: jexp = 4'b1000;
            endcase
        end
    endfunction

    task chk;
        input [3:0] got, exp;
        input [8*10:1] tag;
        begin
            if (got !== exp) begin
                $display("ERROR: %0s got=%b exp=%b t=%0t", tag, got, exp, $time);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_counters.vcd");
        $dumpvars(0, tb_counters);
        repeat (2) @(posedge clk);
        #1;
        chk(up, 4'd0, "up rst");     chk(down, 4'd15, "down rst");
        chk(mod10, 4'd0, "m10 rst"); chk(ring, 4'b0001, "ring rst");
        chk(johnson, 4'd0, "jc rst");
        reset = 0;
        for (i = 1; i <= 40; i = i + 1) begin
            @(posedge clk); #1;
            chk(up,      i % 16,               "up");
            chk(down,    (63 - i) % 16,        "down");
            chk(mod10,   i % 10,               "mod10");
            chk(ring,    4'b0001 << (i % 4),   "ring");
            chk(johnson, jexp(i),              "johnson");
            if (tc10 !== (mod10 == 4'd9)) begin
                $display("ERROR: tc10 wrong at i=%0d", i);
                errors = errors + 1;
            end
        end
        // enable = 0 must freeze all counters
        en = 0;
        @(posedge clk); #1;
        chk(up, 40 % 16, "up hold");
        if (errors == 0) $display("RESULT: PASS tb_counters");
        else             $display("RESULT: FAIL tb_counters (%0d errors)", errors);
        $finish;
    end
endmodule
