# Compile the salagagl library

CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
AR          := $(CC_PREFIX)-ar

INC_DIRS    := -Iinclude/
CFLAGS      := ${LIB_CFLAGS}
CFLAGS      += -Wall -march=rv32i -mabi=ilp32 -O3 $(INC_DIRS)


IO_OBJS  := draw_line.o draw_rectangle.o set_pixel.o sim_draw_rectangle.o sim_set_pixel.o \
            sim_draw_line.o


all: libsalagagl.a

libsalagagl.a: $(IO_OBJS)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -c $^ -o $@ $(CFLAGS)

%.o: %.s
	$(CC) -c $^ -o $@ $(CFLAGS)

clean:
	$(RM) *.o *.a

.PHONY: clean
