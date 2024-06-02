/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause.
 *
 * This module controls a single ws2812b RBG addressable LED.
 *
 * When the module asserts can_accept, it will accept data to display
 * on the next rising clock edge when ena is also asserted.
 *
 * Data are three bytes: {G[7:0],R[7:0],B[7:0]} where the G,
 * R, and B values control the bightness of those colors.
 */

module ws2812b #(parameter CLK_FREQ = 20e6)
(
                input wire        clk,
                input wire        reset_n,
                input wire [23:0] data_in,
                input wire        ena,
                output wire       can_accept,
                output reg        to_din
);

   /* states */
   localparam IDLE = 3'b000;
   localparam CHK_COUNT = 3'b001;
   localparam SEND_HI = 3'b010;
   localparam SEND_LO = 3'b011;
   localparam SEND_RES = 3'b100;

   /* WS2812B timing.  Each bit is encoded by holding din high for a time
    * followed by holding it low for a time:
    *    0: time high: 0.4us, low: 0.85us   (all times have
    *    1: time high: 0.8us, low: 0.45us    margin +/- 150ns)
    * After all LEDs in a string are set, hold din low for "reset" time
    * of at least 300us.  Reg cycle_counter must be wide enough for this.
    * You will also have problems if clock is too slow.  5 MHz is near the
    * lower limit for accurate timing.
    */

   localparam CLKS_PER_BIT = $rtoi(CLK_FREQ*1.25e-6 + 0.5);
   localparam T0H_CLKS = $rtoi(CLK_FREQ*0.4e-6 + 0.5);
   localparam T0L_CLKS = CLKS_PER_BIT - T0H_CLKS;
   localparam T1H_CLKS = $rtoi(CLK_FREQ*0.8e-6 + 0.5);
   localparam T1L_CLKS = CLKS_PER_BIT - T1H_CLKS;
   localparam RES_CLKS = $rtoi(CLK_FREQ*302e-6 + 0.5);

   reg [4:0]   bit_counter;
   reg [14:0]  cycle_counter;
   reg [2:0]   state = IDLE;
   reg [23:0]  grb_val;

   assign can_accept = (state == IDLE);

   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
        state <= IDLE;
        grb_val <= 1'b0;
        bit_counter <= 'b0;
        cycle_counter <= 'b0;
        to_din <= 1'b0;
     end
     else
       case (state)
         IDLE:
           begin
              to_din <= 1'b0;
              bit_counter <= 24;
              grb_val <= data_in;
              if (ena)
                 state <= CHK_COUNT;
              else
                 state <= IDLE;
           end
         CHK_COUNT:
           begin
              if (bit_counter > 'b0) begin
                 cycle_counter <= grb_val[23] ? T1H_CLKS - 1 : T0H_CLKS - 1;
                 state <= SEND_HI;
              end
              else begin
                 cycle_counter <= RES_CLKS;
                 state <= SEND_RES;
              end
           end
         SEND_HI:
           begin
              to_din <= 1'b1;
              if (cycle_counter > 'b0) begin
                 cycle_counter <= cycle_counter - 1;
                 state <= SEND_HI;
              end
              else begin
                 cycle_counter <= grb_val[23] ? T1L_CLKS - 2 : T0L_CLKS - 2;
                 state <= SEND_LO;
              end
           end
         SEND_LO:
           begin
              to_din <= 1'b0;
              if (cycle_counter > 'b0) begin
                 cycle_counter <= cycle_counter - 1;
                 state <= SEND_LO;
              end
              else begin
                 bit_counter <= bit_counter - 1;
                 grb_val <= {grb_val[22:0], 1'b0};
                 state <= CHK_COUNT;
              end
           end
         SEND_RES:
           begin
              to_din <= 1'b0;
              if (cycle_counter > 'b0) begin
                 cycle_counter <= cycle_counter - 1;
                 state <= SEND_RES;
              end
              else begin
                 state <= IDLE;
              end
           end
      endcase

endmodule
