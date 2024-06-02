/* Copyright 2024 Grug Huhler.  License SPDX BSD-2-Clause.
*/

#include "ws2812b.h"

#define RGB_LED ((volatile unsigned int *) 0x80000020)

void set_ws2812b(unsigned int val)
{
  *RGB_LED = val;
}
