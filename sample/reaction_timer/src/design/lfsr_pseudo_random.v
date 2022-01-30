// LFSR based pseudo random 14-bit number generator

module lfsr_pseudo_random
    (
    input  wire       clk, reset,
    input  wire       start,
    output reg        done_tick,
    output wire[13:0] random_num
    );

    // ---------------------------------
    // Free-running counter used as seed
    // ---------------------------------
    // signal declaration
    reg[13:0]  q_reg;
    wire[13:0] q_next;
    always @(posedge clk, posedge reset)
        if (reset)
            q_reg <= 0;
        else
            q_reg <= q_next;
    // next-state logic
    assign q_next = q_reg + 1;

    // ---------
    // LFSR FSMD
    // ---------
    // signal declaration
    reg[1:0]  state_reg, state_next;
    reg[13:0] random_num_reg, random_num_next;
    reg[4:0]  shift_count_reg, shift_count_next;
    wire      linear_feedback;

    // symbolic state declaration
    localparam[1:0]
        idle  = 2'b00,
        shift = 2'b01,
        done  = 2'b10;

    // FSM state and data registers
    always @(posedge clk, posedge reset)
        if (reset)
            begin
                state_reg       <= idle;
                random_num_reg  <= 0;
                shift_count_reg <= 0;
            end
        else
            begin
                state_reg       <= state_next;
                random_num_reg  <= random_num_next;
                shift_count_reg <= shift_count_next;
            end

    // FSM next-state logic
    always @*
    begin
        // defaults
        state_next       = state_reg;
        done_tick        = 1'b0;
        random_num_next  = random_num_reg;
        shift_count_next = shift_count_reg;

        case (state_reg)
            idle:
                if (start)
                    begin
                        random_num_next  = q_reg;
                        shift_count_next = 6'd14;
                        state_next       = shift;
                    end
            shift:
                begin
                    random_num_next  = {random_num_reg[12:0], linear_feedback};
                    shift_count_next = shift_count_reg - 1;
                    if (shift_count_next == 0)
                        state_next = done;
                end
            done:
                begin
                    done_tick = 1'b1;
                    state_next = idle;
                end
            default:
                state_next = idle;
        endcase
    end

    // data path
    assign linear_feedback = !(random_num_reg[13] ^ random_num_reg[4]
                               ^ random_num_reg[2] ^ random_num_reg[0]);

    // output
    assign random_num = random_num_reg;

endmodule
