CORE_NAME      := eka_core_v1
CXX            := g++
VERILATOR      := verilator

VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VER_FLAGS      := -cc --trace -Wall -Wno-UNUSED -Wno-UNDRIVEN --top-module $(CORE_NAME)

CXX_SRC         = $(wildcard src/*.cpp) $(VERILATOR_ROOT)/include/verilated.cpp $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
CXX_INC_DIRS   := -I$(VERILATOR_ROOT)/include -I./obj_dir -I./include
CXX_FLAGS      := -Wall -Wno-sign-compare

all: verilator_srcs test_elf sim_bin

verilator_srcs: obj_dir/V$(CORE_NAME)__verFiles.dat

obj_dir/V$(CORE_NAME)__verFiles.dat: ../rtl/$(wildcard *.sv)
	$(VERILATOR) $(VER_FLAGS) ../rtl/*.sv
	$(MAKE) -C obj_dir -f V$(CORE_NAME).mk

test_elf:
	$(MAKE) -C gen-software-binary -f Makefile all

sim_bin: verilator_srcs test_elf $(CXX_SRC)
	$(CXX) $(CXX_FLAGS) $(CXX_INC_DIRS) $(CXX_SRC) obj_dir/*.o -o $@

clean:
	$(MAKE) -C gen-software-binary -f Makefile clean
	$(RM) -rf obj_dir *_bin *.vcd *.o

.PHONY: all verilator_srcs test_elf clean
