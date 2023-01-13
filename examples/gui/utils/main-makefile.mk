UTILS_DIR    := ../utils

Eka: software hardware_eka

Jala: software hardware_jala

sim: software hardware
	./obj_dir/Vtb

# Compiling software
software:
	$(MAKE) -f $(UTILS_DIR)/compile-software.mk

# Compile a synthesizable model of the hardware
hardware_eka:
	$(MAKE) -f $(UTILS_DIR)/compile-verilator-files.mk Eka

hardware_jala:
	$(MAKE) -f $(UTILS_DIR)/compile-verilator-files.mk Jala

clean:
	rm -f *.vcd *_bin *_actual.dump *.fill
	rm -f *.o *.elf *.bin *.dissasm
	$(MAKE) -f $(UTILS_DIR)/compile-software.mk clean
	$(MAKE) -f $(UTILS_DIR)/compile-verilator-files.mk clean

.PHONY: clean
