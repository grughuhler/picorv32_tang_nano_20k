/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause.
 *
 * This wrapper implements the bus interface to attach a ws2812b
 * instance to a PicoRV32.
 * 
 */

module ws2812b_tgt #(parameter CLK_FREQ = 20e6)
(
      input wire clk,
      input wire reset_n,
      input wire ws2812b_sel,
      input wire we,
      input wire [23:0] wdata,
      output wire ws2812b_ready,
      output wire to_din
);

wire can_accept;
wire ena;

assign ws2812b_ready = ws2812b_sel & can_accept;
assign ena = ws2812b_sel & can_accept & we;


ws2812b #(.CLK_FREQ(CLK_FREQ)) rgb_led
(
      .clk(clk),
      .reset_n(reset_n),
      .data_in(wdata),
      .ena(ena),
      .can_accept(can_accept),
      .to_din(to_din)
);



endmodule
