all: clean main_sim.cpp hw-files/*
	verilator --cc --exe --build --trace main_sim.cpp hw-files/*

clean:
	$(RM) -rf *.vcd obj_dir
