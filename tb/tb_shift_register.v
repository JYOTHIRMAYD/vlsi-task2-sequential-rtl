`timescale 1ns/1ps
module tb_shift_register;
    reg clk = 0, reset = 1, sin = 0;
    wire [3:0] q;
    wire sout;
    integer errors = 0;
    integer k;
    reg [3:0] pattern = 4'b1011;

    shift_register_n #(.N(4)) dut (.clk(clk), .reset(reset), .shift_in(sin), .q(q), .serial_out(sout));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_shift_register.vcd");
        $dumpvars(0, tb_shift_register);
        repeat (2) @(posedge clk);
        #1 reset = 0;
        // shift 1,0,1,1 in (MSB first)
        for (k = 3; k >= 0; k = k - 1) begin
            sin = pattern[k];
            @(posedge clk); #1;
        end
        if (q !== 4'b1011) begin
            $display("ERROR: SIPO q=%b exp=1011", q);
            errors = errors + 1;
        end
        // shift four zeros: bits must emerge on serial_out MSB first
        sin = 0;
        for (k = 3; k >= 0; k = k - 1) begin
            if (sout !== pattern[k]) begin
                $display("ERROR: SISO bit %0d got=%b exp=%b", k, sout, pattern[k]);
                errors = errors + 1;
            end
            @(posedge clk); #1;
        end
        if (q !== 4'b0000) begin
            $display("ERROR: q=%b exp=0000 after flush", q);
            errors = errors + 1;
        end
        if (errors == 0) $display("RESULT: PASS tb_shift_register");
        else             $display("RESULT: FAIL tb_shift_register (%0d errors)", errors);
        $finish;
    end
endmodule
