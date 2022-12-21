# Compile the salagaio library

CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
AR          := $(CC_PREFIX)-ar

CFLAGS      := -Wall -march=rv32i -mabi=ilp32 -O0


ALL_C_OBJS  := $(patsubst %.c, %.o, $(wildcard *.c))
ALL_AS_OBJS := $(patsubst %.s, %.o, $(wildcard *.s))


all: libsalagaio.a

libsalagaio.a: $(ALL_C_OBJS) $(ALL_AS_OBJS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -c $^ -o $@ $(CFLAGS)

%.o: %.s
	$(CC) -c $^ -o $@ $(CFLAGS)

clean:
	$(RM) *.o *.a

.PHONY: clean
