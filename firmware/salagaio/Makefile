# Compile the salagaio library

CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
AR          := $(CC_PREFIX)-ar

INC_DIRS    := -Iinclude/
CFLAGS      := -Wall -march=rv32i -mabi=ilp32 -O3 $(INC_DIRS)


IO_OBJS  := UART.o print.o


all: libsalagaio.a

libsalagaio.a: $(IO_OBJS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -c $^ -o $@ $(CFLAGS)

%.o: %.s
	$(CC) -c $^ -o $@ $(CFLAGS)

clean:
	$(RM) *.o *.a

.PHONY: clean
