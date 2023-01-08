CC_PREFIX    := riscv64-unknown-elf
CC           := $(CC_PREFIX)-gcc
PYTHON       := python3

SLG_IO_INC_DIR  := ../../../firmware/salagaio/include
SLG_IO_LIB_PATH := ../../../firmware/salagaio

CFLAGS       := -Wall -O0 -march=rv32i -mabi=ilp32 -static --specs=nosys.specs -I$(SLG_IO_INC_DIR)
LDFLAGS      := -nostartfiles -T ../utils/linker-file.ld -lm -L$(SLG_IO_LIB_PATH) -lsalagaio

all: imem.fill

imem.fill: program.elf
	$(CC_PREFIX)-objcopy -O binary $^ program.bin
	$(PYTHON) ../utils/make-ascii-bin.py program.bin $@

program.elf: program.o start.o libsalagaio.a
	$(CC) program.o start.o -o $@ $(CFLAGS) $(LDFLAGS)
	$(CC_PREFIX)-objdump -Dz $@ > program.dissasm

program.o: program.c
	$(CC) -c $^ -o program.o $(CFLAGS)

start.o: ../utils/start.s
	$(CC) -c $^ -o start.o $(CFLAGS)

libsalagaio.a:
	$(MAKE) -C $(SLG_IO_LIB_PATH)

clean:
	$(RM) *.o *.elf *.map *.hex *.dissasm *.bin

clean_all: clean
	$(MAKE) -C $(SLG_IO_LIB_PATH) clean


.PHONY: all clean
