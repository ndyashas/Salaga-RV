CC_PREFIX   := riscv64-unknown-elf
CC          := $(CC_PREFIX)-gcc
PYTHON      := python3
PROGRAM     := program

TOOLS_DIR   := ../common
MACH        := rv32i
C_SRC       := $(wildcard *.c) $(TOOLS_DIR)/startup-script.c $(wildcard *.S)
C_OBJ       := $(patsubst %.c, %.o, $(C_SRC))
CFLAGS      := -Wall -static -lm -lgcc -march=$(MACH) -mabi=ilp32 -o0
LDFLAGS     := -nostartfiles -nostdlib -T $(TOOLS_DIR)/linker-file.ld -Wl,-Map=$(PROGRAM)-final.map

all: $(PROGRAM).hex

$(PROGRAM).hex: $(PROGRAM).elf
	$(CC_PREFIX)-objcopy -O binary $^ $(PROGRAM).bin
	$(PYTHON) $(TOOLS_DIR)/make-ascii-bin.py $(PROGRAM).bin $@

$(PROGRAM).elf: $(C_OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
	$(CC_PREFIX)-objdump -Dz $@ > $(PROGRAM).dissasm

%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -rf *.o *.elf *.map *.hex *.dissasm *.bin

.PHONY: all clean
