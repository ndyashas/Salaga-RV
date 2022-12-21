# Compile the salagaio library

CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
AR          := $(CC_PREFIX)-ar

CFLAGS      := -Wall -march=rv32i -mabi=ilp32 -O0


ALL_OBJS    := $(patsubst %.c, %.o, $(wildcard *.c))


all: libsalagaio.a $(ALL_OBJS)

libsalagaio.a: $(ALL_OBJS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -c $^ -o $@ $(CFLAGS)

clean:
	$(RM) *.o *.a

.PHONY: clean
