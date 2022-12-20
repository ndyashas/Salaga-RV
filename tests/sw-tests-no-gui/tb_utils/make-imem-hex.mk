CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
PYTHON      := python3

MACH        := rv32i
CFLAGS      := -Wall -static -lm -lgcc -march=rv32i -mabi=ilp32 -o0
LDFLAGS     := -nostartfiles -T ../tb_utils/linker-file.ld

all: imem.fill

imem.fill: program.elf
	$(CC_PREFIX)-objcopy -O binary $^ program.bin
	$(PYTHON) ../tb_utils/make-ascii-bin.py program.bin $@

program.elf: program.o start.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
	$(CC_PREFIX)-objdump -Dz $@ > program.dissasm

program.o: program.c
	$(CC) $(CFLAGS) -c $^ -o program.o

start.o: ../tb_utils/start.s
	$(CC) $(CFLAGS) -c $^ -o start.o

clean:
	rm -rf *.o *.elf *.map *.hex *.dissasm *.bin

.PHONY: all clean
