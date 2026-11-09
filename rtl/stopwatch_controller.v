`timescale 1ns/1ps
// Configurable digital stopwatch (Exercise 7).
//   CLK_PER_TICK : clock cycles per 1 second (e.g. 50_000_000 for 50 MHz)
//   TICK_W       : width of the tick divider (must hold CLK_PER_TICK-1)
// start_stop : press to toggle RUN/PAUSE (edge-detected)
// clear      : zeroes the time while NOT running
// FSM: IDLE --start--> RUN <--start/stop--> PAUSE --clear--> IDLE
module stopwatch_controller #(
    parameter CLK_PER_TICK = 50_000_000,
    parameter TICK_W       = 26
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       start_stop,
    input  wire       clear,
    output wire [5:0] seconds,
    output wire [5:0] minutes,
    output wire       running
);
    localparam [1:0] IDLE = 2'd0, RUN = 2'd1, PAUSE = 2'd2;

    reg [1:0] state, next_state;
    reg       ss_d;
    wire      ss_pulse = start_stop & ~ss_d;      // rising-edge detect

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            ss_d  <= 1'b0;
        end else begin
            state <= next_state;
            ss_d  <= start_stop;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    if (ss_pulse) next_state = RUN;
            RUN:     if (ss_pulse) next_state = PAUSE;
            PAUSE:   if (clear)         next_state = IDLE;
                     else if (ss_pulse) next_state = RUN;
            default: next_state = IDLE;
        endcase
    end

    assign running = (state == RUN);
    wire clear_cmd = clear & ~running;

    wire tick_tc, sec_tc;

    counter_n #(.N(TICK_W), .MOD(CLK_PER_TICK)) u_tick (
        .clk(clk), .reset(reset), .clr(clear_cmd), .en(running),
        .up_down(1'b1), .q(), .tc(tick_tc)
    );
    wire tick = tick_tc & running;

    counter_n #(.N(6), .MOD(60)) u_sec (
        .clk(clk), .reset(reset), .clr(clear_cmd), .en(tick),
        .up_down(1'b1), .q(seconds), .tc(sec_tc)
    );

    counter_n #(.N(6), .MOD(60)) u_min (
        .clk(clk), .reset(reset), .clr(clear_cmd), .en(tick & sec_tc),
        .up_down(1'b1), .q(minutes), .tc()
    );
endmodule
