/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause.

   This is a VERY incomplete startup sequence for C.  It fails to
   do many things such as clear bss.
*/

.text
.global _start
_start:
	li x2, 4*(1<<SRAM_ADDR_WIDTH)
	call main
