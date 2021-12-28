#include <iostream>
#include <stdlib.h>
#include "Veka_core_v1.h"
#include "verilated.h"
#include "cpu.h"
#include "memory_controller.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	Memory_controller* memory_controller = new Memory_controller();

	CPU<Veka_core_v1>* core = new CPU<Veka_core_v1>(100,
							memory_controller,
							true,
							false);
	core->open_trace("eka_core_v1_sim.vcd");

	core->reset();
	while(!core->done()) {
		core->tick();
	}
	core->close_trace();

	delete memory_controller;
	delete core;
	return 0;
}

	
