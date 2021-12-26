#include <iostream>
#include <stdlib.h>
#include "Veka_core_v1.h"
#include "verilated.h"
#include "cpu.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);	

	CPU<Veka_core_v1> *core = new CPU<Veka_core_v1>(100);

	core->open_trace("eka_core_v1_sim.vcd");
	while(!core->done()) {
		core->tick();
	}
	core->close_trace();

	return 0;
}

	
