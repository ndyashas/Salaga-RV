CC          := riscv64-unknown-elf-gcc
PROGRAM     := add-two-ints

MACH        := rv32i
CFLAGS      := -Wall -static -lm -lgcc -march=$(MACH) -mabi=ilp32
LDFLAGS     := -nostdlib -T linker-file.ld -Wl,-Map=$(PROGRAM)-final.map

all: $(PROGRAM).elf

$(PROGRAM).elf: $(PROGRAM).o startup-script.o
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -rf *.o *.elf *.map *.hex

.PHONY: all clean
