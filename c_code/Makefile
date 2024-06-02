# Just run "make" to create ../src/mem_init.v


# SRAM_ADDR_WIDTH sets the width of the SRAM's address in the Verilog.
# This implicitly sets the total bytes of SRAM to 4*(1 << SRAM_ADDR_WIDTH)
# which, in turn, sets the starting address of the stack pointer in
# startup.s
#
# The practical values are
#   11 - giving 8192 bytes of SRAM (using 4 block SRAMS).
#   12 - giving 16384 bytes of SRAM (using 8 block SRAMS).
#   13 - giving 32768 bytes of SRAM  (using 16 block SRAMS).
#   14 - giving 65536 bytes of SRAM  (using 32 block SRAMS, Nano 20K only).
#
# The Gowin GW1NR-LV9 has only 26 block SRAMS so value 14 will fail.
# The GW2AR-LV18 has 46 blocks so 14 is OK for it.
# Values less than 11 will work but are pointless on this FPGA since
# 4 block SRAMs will still be used.
#
# Note that file force_rebuild.v is empty and exists only to cause
# the Gowan IDE to rebuild when this makefile has executed.

SRAM_ADDR_WIDTH = 12

# This tells both software and Verilog the clock speed.  Change it
# here only.
CLK_FREQ = 20000000

COMMONFLAGS = -march=rv32i2p0 -mabi=ilp32
CFLAGS = -mno-save-restore $(COMMONFLAGS) -nostartfiles -nostdlib -static -O1
ASFLAGS = --defsym SRAM_ADDR_WIDTH=$(SRAM_ADDR_WIDTH) \
          --defsym CLK_FREQ=$(CLK_FREQ) $(COMMONFLAGS)
LIBS = /usr/lib/gcc/riscv64-unknown-elf/10.2.0/rv32i/ilp32/libgcc.a

CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump
AS = riscv64-unknown-elf-as

all: prog.hex conv_to_init

conv_to_init: conv_to_init.c
	gcc -o conv_to_init conv_to_init.c

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

countdown_timer.o: countdown_timer.c
	$(CC) $(CFLAGS) -c countdown_timer.c

uart.o: uart.c
	$(CC) $(CFLAGS) -c uart.c

leds.o: leds.c
	$(CC) $(CFLAGS) -c leds.c

ws2812b.o: ws2812b.c
	$(CC) $(CFLAGS) -c ws2812b.c

startup.o: startup.s Makefile
	$(AS) $(ASFLAGS) -o startup.o startup.s

prog.elf: startup.o main.o countdown_timer.o uart.o leds.o ws2812b.o
	$(CC) $(CFLAGS) -Tlink_cmd.ld -o prog.elf startup.o main.o countdown_timer.o \
          uart.o leds.o ws2812b.o $(LIBS)

prog.bin: prog.elf conv_to_init Makefile
	$(OBJCOPY) prog.elf -O binary prog.bin
	rm -f ../src/mem_init[0-3].ini ../src/sys_parameters.v
	./conv_to_init $(CLK_FREQ) $(SRAM_ADDR_WIDTH) prog.bin
	touch ../src/force_rebuild.v

prog.hex: prog.bin
	od -v -Ax -t x4 prog.bin > prog.hex

clean:
	rm -f prog.elf prog.hex prog.bin main.o conv_to_init countdown_timer.o uart.o \
            startup.o leds.o ws2812b.o

