// Reaction timer testing circuit

module reaction_timer_test
    (
    input wire       clk, reset,
    input wire       btnL, btnR, btnC,
    output wire[3:0] an,
    output wire[7:0] sseg,
    output wire      led
    );

    // signal declaration
    wire       clear, start, stop;
    wire[3:0]  bcd3, bcd2, bcd1, bcd0;
    wire       done_pseudo, start_pseudo;
    wire[13:0] reaction_time, random_num;
    wire       sseg_mesg, sseg_active;

    //==========================================
    // component instantiation
    //==========================================
    // debouncers
    debounce db_clear_unit
        (.clk(clk), .reset(reset), .sw(btnR),
         .db_level(), .db_tick(clear));
    debounce db_start_unit
        (.clk(clk), .reset(reset), .sw(btnC),
         .db_level(), .db_tick(start));
    debounce db_stop_unit
        (.clk(clk), .reset(reset), .sw(btnL),
         .db_level(), .db_tick(stop));
    // reaction timer
    reaction_timer reaction_unit
        (.clk(clk), .reset(reset), .start(start), .clear(clear),
         .stop(stop), .done_pseudo(done_pseudo), .random_num(random_num),
         .reaction_time(reaction_time), .sseg_active(sseg_active),
         .sseg_mesg(sseg_mesg), .reaction_led(led),
         .start_bin2bcd(start_bin2bcd), .start_pseudo(start_pseudo));
    // lfsr pseudo random number generator
    lfsr_pseudo_random pseudo_random_unit
        (.clk(clk), .reset(reset), .start(start_pseudo),
         .done_tick(done_pseudo), .random_num(random_num));
    // binary-to-BCD converters
    bin2bcd b2b_unit
        (.clk(clk), .reset(reset), .start(start_bin2bcd),
         .bin(reaction_time), .ready(), .done_tick(),
         .bcd3(bcd3), .bcd2(bcd2),
         .bcd1(bcd1), .bcd0(bcd0));
    // instance of display unit
    disp_hex_mux disp_unit
         (.clk(clk), .reset(reset),
          .active(sseg_active), .mesg(sseg_mesg),
          .dp_in(4'b0111),
          .hex3(bcd3), .hex2(bcd2), .hex1(bcd1), .hex0(bcd0),
          .an(an), .sseg(sseg));

endmodule
