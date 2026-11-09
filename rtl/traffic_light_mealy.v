`timescale 1ns/1ps
// Mealy FSM traffic light controller: same 4 states/timing as the Moore
// version, plus an 'emergency' input. Outputs depend on state AND input:
// when emergency is high, both lights go red in the SAME cycle (no clock
// edge needed) and the state/timer freeze until emergency is released.
module traffic_light_mealy #(
    parameter GREEN_T  = 6,
    parameter YELLOW_T = 2
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       emergency,
    output reg  [2:0] light_a,
    output reg  [2:0] light_b
);
    localparam [1:0] S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
    localparam [2:0] RED = 3'b100, YEL = 3'b010, GRN = 3'b001;

    reg  [1:0] state, next_state;
    reg  [7:0] timer;

    wire [7:0] dur  = state[0] ? YELLOW_T : GREEN_T;
    wire       done = (timer == dur - 1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 8'd0;
        end else if (!emergency) begin        // freeze during emergency
            state <= next_state;
            timer <= done ? 8'd0 : timer + 8'd1;
        end
    end

    always @(*) begin
        next_state = state;
        if (done) begin
            case (state)
                S0:      next_state = S1;
                S1:      next_state = S2;
                S2:      next_state = S3;
                S3:      next_state = S0;
                default: next_state = S0;
            endcase
        end
    end

    // output logic (Mealy: function of state AND input)
    always @(*) begin
        if (emergency) begin
            light_a = RED; light_b = RED;
        end else begin
            case (state)
                S0:      begin light_a = GRN; light_b = RED; end
                S1:      begin light_a = YEL; light_b = RED; end
                S2:      begin light_a = RED; light_b = GRN; end
                S3:      begin light_a = RED; light_b = YEL; end
                default: begin light_a = RED; light_b = RED; end
            endcase
        end
    end
endmodule
