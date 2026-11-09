`timescale 1ns/1ps
// Mealy traffic light: normal sequence matches Moore; 'emergency' forces both
// lights red combinationally and freezes the FSM.
module tb_traffic_mealy;
    localparam G = 4, Y = 2, PERIOD = 2*G + 2*Y;
    localparam [2:0] RED = 3'b100, YEL = 3'b010, GRN = 3'b001;

    reg clk = 0, reset = 1, emergency = 0;
    wire [2:0] la, lb;
    integer errors = 0;
    integer k = 0;

    traffic_light_mealy #(.GREEN_T(G), .YELLOW_T(Y)) dut (
        .clk(clk), .reset(reset), .emergency(emergency), .light_a(la), .light_b(lb));

    always #5 clk = ~clk;

    // model: k advances only on edges where emergency is low
    always @(posedge clk or posedge reset) begin
        if (reset)           k <= 0;
        else if (!emergency) k <= k + 1;
    end

    function [2:0] exp_a;
        input integer n;
        integer p;
        begin
            p = n % PERIOD;
            if      (p < G)     exp_a = GRN;
            else if (p < G + Y) exp_a = YEL;
            else                exp_a = RED;
        end
    endfunction

    function [2:0] exp_b;
        input integer n;
        integer p;
        begin
            p = n % PERIOD;
            if      (p < G + Y)   exp_b = RED;
            else if (p < 2*G + Y) exp_b = GRN;
            else                  exp_b = YEL;
        end
    endfunction

    reg checking = 0;
    always @(negedge clk) if (checking) begin
        if (emergency) begin
            if (la !== RED || lb !== RED) begin
                $display("ERROR: emergency lights la=%b lb=%b", la, lb);
                errors = errors + 1;
            end
        end else if (la !== exp_a(k) || lb !== exp_b(k)) begin
            $display("ERROR: k=%0d la=%b lb=%b exp_a=%b exp_b=%b", k, la, lb, exp_a(k), exp_b(k));
            errors = errors + 1;
        end
    end

    initial begin
        $dumpfile("sim/tb_traffic_mealy.vcd");
        $dumpvars(0, tb_traffic_mealy);
        repeat (2) @(posedge clk);
        #1 reset = 0;
        checking = 1;
        repeat (PERIOD + 2) @(posedge clk);       // run into the middle of a state
        #2 emergency = 1;                          // mid-cycle
        #1 if (la !== RED || lb !== RED) begin     // Mealy: reacts with NO clock edge
            $display("ERROR: emergency not immediate");
            errors = errors + 1;
        end
        repeat (5) @(posedge clk);                 // frozen for 5 cycles
        #2 emergency = 0;
        repeat (2 * PERIOD) @(posedge clk);        // sequence resumes where it stopped
        if (errors == 0) $display("RESULT: PASS tb_traffic_mealy");
        else             $display("RESULT: FAIL tb_traffic_mealy (%0d errors)", errors);
        $finish;
    end
endmodule
