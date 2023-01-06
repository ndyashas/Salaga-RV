CC_PREFIX    := riscv64-unknown-elf
CC           := $(CC_PREFIX)-gcc
PYTHON       := python3
FIRMWARE_DIR := ../../../firmware

UTILS_SW_DIR := ../utils/software

SLG_INC_DIR  := $(FIRMWARE_DIR)/salagalib/include
SLG_LIB_PATH := $(FIRMWARE_DIR)/salagalib

CFLAGS       := -Wall -O0 -march=rv32i -mabi=ilp32 -static --specs=nosys.specs -I$(SLG_INC_DIR)
LDFLAGS      := -nostartfiles -T $(UTILS_SW_DIR)/linker-file.ld -lm -L$(SLG_LIB_PATH) -lsalagaio

all: mem.fill

mem.fill: program.elf
	$(CC_PREFIX)-objcopy -O binary $^ program.bin
	$(PYTHON) $(UTILS_SW_DIR)/make-ascii-bin.py program.bin imem.fill
	cp imem.fill dmem.fill

program.elf: program.o start.o libsalagaio.a
	$(CC) program.o start.o -o $@ $(CFLAGS) $(LDFLAGS)
	$(CC_PREFIX)-objdump -Dz $@ > program.dissasm

program.o: program.c
	$(CC) -c $^ -o program.o $(CFLAGS)

start.o: $(UTILS_SW_DIR)/start.s
	$(CC) -c $^ -o start.o $(CFLAGS)

libsalagaio.a:
	$(MAKE) -C $(SLG_LIB_PATH)

clean:
	$(RM) *.o *.elf *.map *.hex *.dissasm *.bin
	$(MAKE) -C $(SLG_LIB_PATH) clean


.PHONY: all clean
