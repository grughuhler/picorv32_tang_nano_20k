//Copyright (C)2014-2024 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.9 Beta-4 Education
//Created Time: 2024-06-01 16:16:50
create_clock -name clk -period 50 -waveform {0 25} [get_ports {clk}]
