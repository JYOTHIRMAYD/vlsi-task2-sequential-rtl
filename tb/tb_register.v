`timescale 1ns/1ps
module tb_register;
    reg clk = 0, reset = 0, en = 0;
    reg [7:0] d = 0;
    wire [7:0] q_a, q_s;
    integer errors = 0;

    register8 #(.ASYNC_RESET(1)) u_a (.clk(clk), .reset(reset), .en(en), .d(d), .q(q_a));
    register8 #(.ASYNC_RESET(0)) u_s (.clk(clk), .reset(reset), .en(en), .d(d), .q(q_s));

    always #5 clk = ~clk;

    task chk;
        input [7:0] got, exp;
        input [8*12:1] tag;
        begin
            if (got !== exp) begin
                $display("ERROR: %0s got=%h exp=%h t=%0t", tag, got, exp, $time);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_register.vcd");
        $dumpvars(0, tb_register);

        #2 reset = 1;
        #1 chk(q_a, 8'h00, "async rst");
        @(posedge clk); #1;
        chk(q_a, 8'h00, "a reset");
        chk(q_s, 8'h00, "s reset");
        reset = 0; en = 1; d = 8'hA5;
        @(posedge clk); #1;
        chk(q_a, 8'hA5, "a load");
        chk(q_s, 8'hA5, "s load");
        en = 0; d = 8'h3C;                       // hold when en = 0
        @(posedge clk); #1;
        chk(q_a, 8'hA5, "a hold");
        chk(q_s, 8'hA5, "s hold");
        en = 1;
        @(posedge clk); #1;
        chk(q_a, 8'h3C, "a load2");
        chk(q_s, 8'h3C, "s load2");
        #1 reset = 1;                            // mid-cycle reset
        #1 chk(q_a, 8'h00, "a async");
        chk(q_s, 8'h3C, "s waits");
        @(posedge clk); #1;
        chk(q_s, 8'h00, "s sync");
        reset = 0;
        #20;
        if (errors == 0) $display("RESULT: PASS tb_register");
        else             $display("RESULT: FAIL tb_register (%0d errors)", errors);
        $finish;
    end
endmodule
