// Reaction timer

module reaction_timer
    (
    input  wire       clk, reset,
    input  wire       start, clear, stop,
    input  wire       done_pseudo,
    input  wire[13:0] random_num,
    output wire[13:0] reaction_time,
    output reg        sseg_active, sseg_mesg,
    output reg        reaction_led,
    output reg        start_pseudo,
    output reg        start_bin2bcd
    );

    // symbolic state declaration
    localparam[2:0]
        idle             = 3'b000,
        get_random_num   = 3'b001,
        retry_random_num = 3'b110,
        random_timer     = 3'b010,
        reaction_timer   = 3'b011,
        fail             = 3'b100,
        done             = 3'b101;

    // constant declarations
    localparam CLK_MS_COUNT      = 100_000,   // 1ms tick (10ns clk)
               REACTION_TIME_MAX = 1_000,     // 1s in ms
               RAND_NUM_MIN      = 2_000,     // Minimum random interval (ms)
               RAND_NUM_MAX      = 15_000;    // Maximum random interval (ms)

    // signal declaration
    reg[2:0]  state_reg,    state_next;
    reg[16:0] tick_reg,     tick_next;     // up to CLK_MS_COUNT
    reg[13:0] period_reg,   period_next;   // up to 15s with 1ms tick
    reg[13:0] random_reg,   random_next;   // up to 15s with 1ms tick
    reg[13:0] reaction_reg, reaction_next; // up to 9.999s with 1ms tick

    // body
    // FSM state and data registers
    always @(posedge clk, posedge reset)
        if (reset)
            begin
                state_reg    <= idle;
                tick_reg     <= 0;
                period_reg   <= 0;
                random_reg   <= 0;
                reaction_reg <= 0;
            end
        else
            begin
                state_reg    <= state_next;
                tick_reg     <= tick_next;
                period_reg   <= period_next;
                random_reg   <= random_next;
                reaction_reg <= reaction_next;
            end

    // FSMD next-state logic
    always @*
    begin
        state_next    = state_reg;
        tick_next     = tick_reg;
        period_next   = period_reg;
        random_next   = random_reg;
        reaction_next = reaction_reg;
        sseg_active   = 1'b0;
        sseg_mesg     = 1'b0;
        start_pseudo  = 1'b0;
        start_bin2bcd = 1'b0;
        reaction_led  = 1'b0;
        case (state_reg)
            idle:
                begin
                    sseg_active = 1'b1;
                    sseg_mesg   = 1'b1;
                    if (start)
                        begin
                            state_next   = get_random_num;
                            start_pseudo = 1'b1;
                        end
                end
            get_random_num:
                begin
                    if (done_pseudo)
                        begin
                            // reject and try again if not between 2 and 15s
                            if (random_num < RAND_NUM_MIN
                                || random_num > RAND_NUM_MAX)
                                state_next = retry_random_num;
                            else
                                begin
                                    random_next = random_num;
                                    state_next  = random_timer;
                                    tick_next   = 0;
                                    period_next = 0;
                                end
                        end
                end
            // This state is required to wait for the pseudo-random
            // generator to exit its done state before another start
            retry_random_num:
                begin
                    start_pseudo = 1'b1;
                    state_next = get_random_num;
                end
            random_timer:
                begin
                    if (tick_reg == CLK_MS_COUNT - 1) // 1ms tick
                        begin
                            tick_next   = 0;
                            period_next = period_reg + 1;
                        end
                    else
                        tick_next = tick_reg + 1;
                    if (period_reg == random_reg)
                        begin
                            state_next    = reaction_timer;
                            reaction_next = 0;
                            tick_next     = 0;
                        end
                end
            reaction_timer:
                begin
                    sseg_active = 1'b1;
                    reaction_led = 1'b1;
                    if (reaction_reg == REACTION_TIME_MAX + 1)
                        begin
                            start_bin2bcd = 1'b1;
                            state_next    = fail;
                        end
                    else if (stop == 1'b1)
                        begin
                            start_bin2bcd = 1'b1;
                            state_next    = done;
                        end
                    else if (tick_reg == CLK_MS_COUNT - 1)
                        begin
                            start_bin2bcd = 1'b1;
                            tick_next     = 0;
                            reaction_next = reaction_reg + 1;
                        end
                    else
                        tick_next = tick_reg + 1;
                end
            fail:
                begin
                    sseg_active = 1'b1;
                    if (clear == 1)
                        state_next = idle;
                end
            done:
                begin
                    sseg_active  = 1'b1;
                    reaction_led = 1'b1;
                    if (clear == 1)
                        begin
                            state_next    = idle;
                            reaction_next = 0;
                        end
                end
        endcase
    end

assign reaction_time = reaction_reg;

endmodule