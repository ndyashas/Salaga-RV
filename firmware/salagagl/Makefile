# Compile the salagagl library

CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
AR          := $(CC_PREFIX)-ar

FIRMWARE_DIR := ..

SLG_INC_DIR  := $(FIRMWARE_DIR)/salagalib/include
SLG_LIB_PATH := $(FIRMWARE_DIR)/salagalib

INC_DIRS    := -Iinclude/
INC_DIRS    += -I$(SLG_INC_DIR)

CFLAGS      := -Wall -march=rv32i -mabi=ilp32 -O0 $(INC_DIRS)
LDFLAGS     := -L$(SLG_LIB_PATH) -lsalagaio

GL_OBJS  := draw_line.o


all: libsalagagl.a

libsalagagl.a: $(GL_OBJS)
	$(AR) rcs $@ $^

%.o: %.c libsalagaio.a
	$(CC) -c $< -o $@ $(CFLAGS) $(LDFLAGS)

%.o: %.s libsalagaio.a
	$(CC) -c $< -o $@ $(CFLAGS) $(LDFLAGS)

libsalagaio.a:
	$(MAKE) -C $(SLG_LIB_PATH)

clean:
	$(RM) *.o *.a
	$(MAKE) -C $(SLG_LIB_PATH) clean

.PHONY: clean
