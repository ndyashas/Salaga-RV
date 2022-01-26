CORE_NAME      := salaga_chip
CXX            := g++
VERILATOR      := verilator

VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')
VER_FLAGS      := -cc --trace --trace-max-array 128 -Wall -Wno-UNUSED --top-module $(CORE_NAME)

CXX_SRC         = $(wildcard src/*.cpp) $(VERILATOR_ROOT)/include/verilated.cpp $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
CXX_INC_DIRS   := -I$(VERILATOR_ROOT)/include -I./obj_dir -I./include
CXX_FLAGS      := -Wall -Wno-sign-compare
CORE_TO_BUILD  := $(shell bash -c 'cat config/config.svh | grep "^\`define CORE_VARIANT" | awk "{ print \$$3 }"')


all: sim_host.elf test_prog_deps

sim_host.elf: obj_dir/V$(CORE_NAME)__verFiles.dat $(CXX_SRC)
	$(CXX) $(CXX_FLAGS) $(CXX_INC_DIRS) $(CXX_SRC) obj_dir/*.o -o $@

obj_dir/V$(CORE_NAME)__verFiles.dat: ../rtl/$(CORE_TO_BUILD)/$(wildcard *.sv) rtl_top_level_wrapper/$(wildcard *.sv)
	$(VERILATOR) $(VER_FLAGS) ../rtl/$(CORE_TO_BUILD)/*.sv rtl_top_level_wrapper/*.sv
	$(MAKE) -C obj_dir -f V$(CORE_NAME).mk

test_prog_deps: test-sw
	$(MAKE) -C test-sw -f Makefile all

clean:
	$(RM) -rf obj_dir *_host.elf *.vcd *.o
	$(MAKE) -C test-sw -f Makefile clean

.PHONY: all clean
