UTILS_VER_DIR   := ../utils/verilator_files
RTL_DIR         := ../../../RTL

VERILATOR_OPTS  := --cc --exe --build
# VERILATOR_OPTS  += --threads 4
# VERILATOR_OPTS  +=  --trace -CFLAGS "-DVERILATOR_WAVE_TRACE"
VERILATOR_OPTS  += -CFLAGS "`sdl2-config --cflags`" -LDFLAGS "`sdl2-config --libs`"
VERILATOR_OPTS  += -Wno-TIMESCALEMOD -Wno-CASEINCOMPLETE -Wno-WIDTH -Wno-UNOPTFLAT

VERILATOR_SRCS  := $(UTILS_VER_DIR)/tb.v $(UTILS_VER_DIR)/sim_main.cpp $(UTILS_VER_DIR)/salaga_display.cpp
VERILATOR_SRCS  += $(RTL_DIR)/SoC.v $(RTL_DIR)/MEM/* $(RTL_DIR)/IO/*


Eka: $(VERILATOR_SRCS) $(RTL_DIR)/CORES/Eka/*
	verilator $(VERILATOR_OPTS) $(VERILATOR_SRCS) $(RTL_DIR)/CORES/Eka/*
	cp obj_dir/Vtb test_bin

Jala: $(VERILATOR_SRCS) $(RTL_DIR)/CORES/Jala/*
	verilator $(VERILATOR_OPTS) $(VERILATOR_SRCS) $(RTL_DIR)/CORES/Jala/*
	cp obj_dir/Vtb test_bin

clean:
	$(RM) -r obj_dir test_bin
