CORE_NAME      := eka_core_v1
CXX            := g++
VERILATOR      := verilator

VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VER_FLAGS      := -cc --trace -Wall -Wno-UNUSED -Wno-UNDRIVEN --top-module $(CORE_NAME)

CXX_SRC         = $(wildcard src/*.cpp) $(VERILATOR_ROOT)/include/verilated.cpp $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
CXX_INC_DIRS   := -I$(VERILATOR_ROOT)/include -I./obj_dir -I./include
CXX_FLAGS      := -Wall -Wno-sign-compare


all: sim_host.elf

test_prog_deps: gen-software-binary
	$(MAKE) -C gen-software-binary -f Makefile all

sim_host.elf: test_prog_deps obj_dir/V$(CORE_NAME)__verFiles.dat $(CXX_SRC)
	$(CXX) $(CXX_FLAGS) $(CXX_INC_DIRS) $(CXX_SRC) obj_dir/*.o -o $@

obj_dir/V$(CORE_NAME)__verFiles.dat: ../rtl/$(wildcard *.sv)
	$(VERILATOR) $(VER_FLAGS) ../rtl/*.sv
	$(MAKE) -C obj_dir -f V$(CORE_NAME).mk

clean:
	$(RM) -rf obj_dir *_host.elf *.vcd *.o
	$(MAKE) -C gen-software-binary -f Makefile clean

.PHONY: all clean
