/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause. */

// Create sram using Verilog inference with each 8-bit RAM initialized
// with its own init file.

module sram
  #(parameter SRAM_ADDR_WIDTH=11)
   (
    input wire                 clk,
    input wire                 reset_n,
    input wire                 sram_sel,
    input wire [3:0]           wstrb,
    input wire [SRAM_ADDR_WIDTH + 1:0] addr,
    input wire [31:0]          sram_data_i,
    output wire                sram_ready,
    output wire [31:0]         sram_data_o
    );

   reg                         ready = 1'b0;

   assign sram_ready = ready;

sram8
  #(
    .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH),
    .MEM_INIT_FILE("mem_init3.ini")
    ) gmem3
   (
    .clk(clk),
    .reset_n(reset_n),
    .ce(sram_sel), 
    .wre(wstrb[3]),
    .addr(addr[SRAM_ADDR_WIDTH + 1:2]),
    .data_in(sram_data_i[31:24]),
    .data_out(sram_data_o[31:24])
    );

sram8
  #(
    .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH),
    .MEM_INIT_FILE("mem_init2.ini")
    ) gmem2
   (
    .clk(clk),
    .reset_n(reset_n),
    .ce(sram_sel), 
    .wre(wstrb[2]),
    .addr(addr[SRAM_ADDR_WIDTH + 1:2]),
    .data_in(sram_data_i[23:16]),
    .data_out(sram_data_o[23:16])
    );

sram8
  #(
    .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH),
    .MEM_INIT_FILE("mem_init1.ini")
    ) gmem1
   (
    .clk(clk),
    .reset_n(reset_n),
    .ce(sram_sel), 
    .wre(wstrb[1]),
    .addr(addr[SRAM_ADDR_WIDTH + 1:2]),
    .data_in(sram_data_i[15:8]),
    .data_out(sram_data_o[15:8])
    );

sram8
  #(
    .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH),
    .MEM_INIT_FILE("mem_init0.ini")
    ) gmem0
   (
    .clk(clk),
    .reset_n(reset_n),
    .ce(sram_sel), 
    .wre(wstrb[0]),
    .addr(addr[SRAM_ADDR_WIDTH + 1:2]),
    .data_in(sram_data_i[7:0]),
    .data_out(sram_data_o[7:0])
    );

   always @(posedge clk) 
     if (sram_sel)
        ready <= 1'b1;
     else
        ready <= 1'b0;
   
endmodule // sram
