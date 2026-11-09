`timescale 1ns/1ps
// Verifies parameterized modules at several widths / moduli.
module tb_param;
    reg clk = 0, reset = 1, en = 0, cnt_en = 0, up_down = 1, sin = 0;
    reg [15:0] data = 0;
    integer errors = 0;
    integer i, m10;

    wire [3:0]  r4;   wire [7:0] r8;   wire [15:0] r16;
    wire [2:0]  c3;   wire [7:0] c8;   wire [3:0]  c10;
    wire        tc3, tc8, tc10;
    wire [3:0]  s4;   wire [7:0] s8;   wire [15:0] s16;

    register_n #(.N(4))  u_r4  (.clk(clk), .reset(reset), .en(en), .d(data[3:0]), .q(r4));
    register_n #(.N(8))  u_r8  (.clk(clk), .reset(reset), .en(en), .d(data[7:0]), .q(r8));
    register_n #(.N(16)) u_r16 (.clk(clk), .reset(reset), .en(en), .d(data),      .q(r16));

    counter_n #(.N(3))              u_c3  (.clk(clk), .reset(reset), .clr(1'b0), .en(cnt_en), .up_down(1'b1),    .q(c3),  .tc(tc3));
    counter_n #(.N(8), .MOD(100))   u_c8  (.clk(clk), .reset(reset), .clr(1'b0), .en(cnt_en), .up_down(1'b1),    .q(c8),  .tc(tc8));
    counter_n #(.N(4), .MOD(10))    u_c10 (.clk(clk), .reset(reset), .clr(1'b0), .en(cnt_en), .up_down(up_down), .q(c10), .tc(tc10));

    shift_register_n #(.N(4))  u_s4  (.clk(clk), .reset(reset), .shift_in(sin), .q(s4),  .serial_out());
    shift_register_n #(.N(8))  u_s8  (.clk(clk), .reset(reset), .shift_in(sin), .q(s8),  .serial_out());
    shift_register_n #(.N(16)) u_s16 (.clk(clk), .reset(reset), .shift_in(sin), .q(s16), .serial_out());

    always #5 clk = ~clk;

    task chk;
        input [15:0] got, exp;
        input [8*10:1] tag;
        begin
            if (got !== exp) begin
                $display("ERROR: %0s got=%h exp=%h t=%0t", tag, got, exp, $time);
                errors = errors + 1;
            end
        end
    endtask

    reg [15:0] held;
    reg [15:0] pat = 16'hA53C;

    initial begin
        $dumpfile("sim/tb_param.vcd");
        $dumpvars(0, tb_param);
        repeat (2) @(posedge clk);
        #1 reset = 0;

        // ---- registers (N = 4, 8, 16)
        for (i = 0; i < 8; i = i + 1) begin
            data = $random; en = 1;
            @(posedge clk); #1;
            chk(r4,  data[3:0], "r4");
            chk(r8,  data[7:0], "r8");
            chk(r16, data,      "r16");
        end
        held = data; en = 0; data = ~data;
        @(posedge clk); #1;
        chk(r4, held[3:0], "r4 hold"); chk(r8, held[7:0], "r8 hold"); chk(r16, held, "r16 hold");

        // ---- counters: N=3 free-run, N=8 MOD=100, N=4 MOD=10 up then down then up
        cnt_en = 1; m10 = 0;
        for (i = 1; i <= 250; i = i + 1) begin
            up_down = (i <= 25) || (i > 35);
            if (up_down) m10 = (m10 + 1) % 10; else m10 = (m10 + 9) % 10;
            @(posedge clk); #1;
            chk(c3,  i % 8,   "c3");
            chk(c8,  i % 100, "c8");
            chk(c10, m10,     "c10");
        end

        // ---- shift registers: 16 bits MSB-first, N=4/8/16 keep the last N bits
        for (i = 15; i >= 0; i = i - 1) begin
            sin = pat[i];
            @(posedge clk); #1;
        end
        chk(s16, pat,        "s16");
        chk(s8,  pat[7:0],   "s8");
        chk(s4,  pat[3:0],   "s4");

        if (errors == 0) $display("RESULT: PASS tb_param");
        else             $display("RESULT: FAIL tb_param (%0d errors)", errors);
        $finish;
    end
endmodule
