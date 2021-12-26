core_name := eka_core_v1

VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e " s/^.*=\s*//"')

include_paths := -I$(VERILATOR_ROOT)/include -I./obj_dir
vinclude_src  := $(VERILATOR_ROOT)/include/verilated.cpp
vflags        := -cc

$(core_name)_bin: obj_dir/V$(core_name)__ALL.o main_sim.cpp
	g++ $(include_paths) $(vinclude_src) $^ -o $@

obj_dir/V$(core_name)__ALL.o: obj_dir/V$(core_name)__verFiles.dat
	$(MAKE) -C obj_dir -f V$(core_name).mk

obj_dir/V$(core_name)__verFiles.dat: hw-files/$(wildcard *.sv)
	verilator -cc hw-files/*.sv

clean:
	$(RM) -rf obj_dir *_bin *.vcd
