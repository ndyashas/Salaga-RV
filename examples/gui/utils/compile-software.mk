CC_PREFIX    := riscv64-unknown-elf
CC           := $(CC_PREFIX)-gcc
PYTHON       := python3
FIRMWARE_DIR := ../../../firmware

UTILS_SW_DIR := ../utils/software

SLG_LIB_INC_DIR  := $(FIRMWARE_DIR)/salagalib/include
SLG_LIB_LIB_PATH := $(FIRMWARE_DIR)/salagalib

SLG_IO_INC_DIR  := $(FIRMWARE_DIR)/salagaio/include
SLG_IO_LIB_PATH := $(FIRMWARE_DIR)/salagaio

SLG_GL_INC_DIR  := $(FIRMWARE_DIR)/salagagl/include
SLG_GL_LIB_PATH := $(FIRMWARE_DIR)/salagagl

CFLAGS       := -Wall -O3 -march=rv32i -mabi=ilp32 -static --specs=nosys.specs
CFLAGS       += -I$(SLG_GL_INC_DIR) -I$(SLG_IO_INC_DIR) -I$(SLG_LIB_INC_DIR)
LIB_CFLAGS   += -DSALAGA_SIM

LDFLAGS      := -nostartfiles -T $(UTILS_SW_DIR)/linker-file.ld
LDFLAGS      += -lm -L$(SLG_GL_LIB_PATH) -L$(SLG_IO_LIB_PATH) -L$(SLG_LIB_LIB_PATH)
LDFLAGS      += -lsalagagl -lsalagaio -lsalagalib

all: mem.fill

mem.fill: program.elf
	$(CC_PREFIX)-objcopy -O binary $^ program.bin
	$(PYTHON) ../../../tools/make-ascii-bin.py program.bin imem.fill
	cp imem.fill dmem.fill

program.elf: program.o start.o libsalagaio.a libsalagagl.a libsalagalib.a
	$(CC) program.o start.o -o $@ $(CFLAGS) $(LDFLAGS)
	$(CC_PREFIX)-objdump -Dz $@ > program.dissasm

program.o: program.c
	$(CC) -c $^ -o program.o $(CFLAGS)

start.o: $(UTILS_SW_DIR)/start.s
	$(CC) -c $^ -o start.o $(CFLAGS)

libsalagalib.a:
	$(MAKE) -C $(SLG_LIB_LIB_PATH) LIB_CFLAGS=$(LIB_CFLAGS)

libsalagaio.a:
	$(MAKE) -C $(SLG_IO_LIB_PATH) LIB_CFLAGS=$(LIB_CFLAGS)

libsalagagl.a:
	$(MAKE) -C $(SLG_GL_LIB_PATH) LIB_CFLAGS=$(LIB_CFLAGS)

clean:
	$(RM) *.o *.elf *.map *.hex *.dissasm *.bin
	$(MAKE) -C $(SLG_LIB_LIB_PATH) clean
	$(MAKE) -C $(SLG_IO_LIB_PATH) clean
	$(MAKE) -C $(SLG_GL_LIB_PATH) clean


.PHONY: all clean
