`timescale 1ns/1ps
// Cycle-accurate check of the Moore traffic light (GREEN_T=4, YELLOW_T=2).
module tb_traffic_moore;
    localparam G = 4, Y = 2, PERIOD = 2*G + 2*Y;
    localparam [2:0] RED = 3'b100, YEL = 3'b010, GRN = 3'b001;

    reg clk = 0, reset = 1;
    wire [2:0] la, lb;
    integer errors = 0;
    integer k = 0;

    traffic_light_moore #(.GREEN_T(G), .YELLOW_T(Y)) dut (.clk(clk), .reset(reset), .light_a(la), .light_b(lb));

    always #5 clk = ~clk;

    // reference model: k = clock edges since reset release
    always @(posedge clk or posedge reset) begin
        if (reset) k <= 0;
        else       k <= k + 1;
    end

    function [2:0] exp_a;
        input integer n;
        integer p;
        begin
            p = n % PERIOD;
            if      (p < G)         exp_a = GRN;
            else if (p < G + Y)     exp_a = YEL;
            else                    exp_a = RED;
        end
    endfunction

    function [2:0] exp_b;
        input integer n;
        integer p;
        begin
            p = n % PERIOD;
            if      (p < G)         exp_b = RED;
            else if (p < G + Y)     exp_b = RED;
            else if (p < 2*G + Y)   exp_b = GRN;
            else                    exp_b = YEL;
        end
    endfunction

    reg checking = 0;
    always @(negedge clk) if (checking) begin
        if (la !== exp_a(k) || lb !== exp_b(k)) begin
            $display("ERROR: k=%0d la=%b lb=%b exp_a=%b exp_b=%b", k, la, lb, exp_a(k), exp_b(k));
            errors = errors + 1;
        end
    end

    initial begin
        $dumpfile("sim/tb_traffic_moore.vcd");
        $dumpvars(0, tb_traffic_moore);
        repeat (2) @(posedge clk);
        #1 reset = 0;
        checking = 1;
        repeat (3 * PERIOD) @(posedge clk);       // three full cycles
        // async reset mid-run: back to S0 immediately
        #2 reset = 1;
        #1 if (la !== GRN || lb !== RED) begin
            $display("ERROR: reset did not return to S0");
            errors = errors + 1;
        end
        checking = 0;
        @(posedge clk); #1 reset = 0;
        checking = 1;
        repeat (PERIOD) @(posedge clk);
        if (errors == 0) $display("RESULT: PASS tb_traffic_moore");
        else             $display("RESULT: FAIL tb_traffic_moore (%0d errors)", errors);
        $finish;
    end
endmodule
