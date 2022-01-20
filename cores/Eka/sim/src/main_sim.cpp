#include <iostream>
#include <stdlib.h>
#include "verilated.h"
#include "Veka_chip.h"
#include "cpu.h"
#include "misc.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	if (argc != 2) {
		fprintf(stderr, "Usage: sim_host.elf <Path-to-sim-hex-file>\n");
		return 1;
	}

	CPU<Veka_chip>* core = new CPU<Veka_chip>(100,
						  true,
						  false);

	load_cache(core, I_CACHE, CACHE_SIZE/4, argv[1]);
	load_cache(core, D_CACHE, CACHE_SIZE/4, argv[1]);

	core->open_trace("eka_chip_sim.vcd");
	while(!core->done()) {
		core->tick();
	}
	core->close_trace();

	delete core;

	return 0;
}

	
