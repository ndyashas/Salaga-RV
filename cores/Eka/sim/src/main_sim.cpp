#include <iostream>
#include <stdlib.h>
#include "Veka_core_v1.h"
#include "verilated.h"
#include "cpu.h"
#include "memory_controller.h"
#include "misc.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	if (argc != 2) {
		fprintf(stderr, "Usage: sim_host.elf <Path-to-sim-hex-file>\n");
		return 1;
	}

	unsigned int* l1_inst_cache = new unsigned int[I_CACHE_SIZE];
	unsigned int* l1_data_cache = new unsigned int[D_CACHE_SIZE];

	load_i_cache(l1_inst_cache, I_CACHE_SIZE/4, argv[1]);
	std::cout << "Here\n";

	Memory_controller* memory_controller = new Memory_controller(l1_inst_cache,
								     I_CACHE_SIZE/4,
								     l1_data_cache,
								     D_CACHE_SIZE/4);

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

	core->print_Regfile();
	memory_controller->l1_inst_cache_print(32);
	memory_controller->l1_data_cache_print(48);

	delete memory_controller;
	delete core;
	delete[] l1_inst_cache;
	delete[] l1_data_cache;
	return 0;
}

	
