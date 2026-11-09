`timescale 1ns/1ps
// Moore FSM traffic light controller (two roads, A and B).
// Outputs depend ONLY on the current state.
//   S0: A green,  B red     (GREEN_T  clock cycles)
//   S1: A yellow, B red     (YELLOW_T clock cycles)
//   S2: A red,    B green   (GREEN_T  clock cycles)
//   S3: A red,    B yellow  (YELLOW_T clock cycles)
// Light encoding: {red, yellow, green}
module traffic_light_moore #(
    parameter GREEN_T  = 6,
    parameter YELLOW_T = 2
)(
    input  wire       clk,
    input  wire       reset,     // async, active high
    output reg  [2:0] light_a,
    output reg  [2:0] light_b
);
    localparam [1:0] S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
    localparam [2:0] RED = 3'b100, YEL = 3'b010, GRN = 3'b001;

    reg  [1:0] state, next_state;
    reg  [7:0] timer;

    wire [7:0] dur  = state[0] ? YELLOW_T : GREEN_T;   // odd states = yellow
    wire       done = (timer == dur - 1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 8'd0;
        end else begin
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

    // output logic (Moore: function of state only)
    always @(*) begin
        case (state)
            S0:      begin light_a = GRN; light_b = RED; end
            S1:      begin light_a = YEL; light_b = RED; end
            S2:      begin light_a = RED; light_b = GRN; end
            S3:      begin light_a = RED; light_b = YEL; end
            default: begin light_a = RED; light_b = RED; end
        endcase
    end
endmodule
