core_name := eka_core_v1

VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')

include_paths := -I$(VERILATOR_ROOT)/include -I./obj_dir -I./include
vinclude_src  := $(VERILATOR_ROOT)/include/verilated.cpp $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
vflags        := -cc --trace
cpp_src       := src/main_sim.cpp

$(core_name)_bin: obj_dir/V$(core_name)__ALL.o $(cpp_src)
	g++ $(include_paths) $(vinclude_src) $^ -o $@

obj_dir/V$(core_name)__ALL.o: obj_dir/V$(core_name)__verFiles.dat
	$(MAKE) -C obj_dir -f V$(core_name).mk

obj_dir/V$(core_name)__verFiles.dat: ../rtl/$(wildcard *.sv)
	verilator $(vflags) ../rtl/*.sv

clean:
	$(RM) -rf obj_dir *_bin *.vcd
