#include <iostream>
#include <fstream>
#include <stdlib.h>
#include "verilated.h"
#include "Vsalaga_chip.h"
#include "Vsalaga_chip___024root.h"
#include "cpu.h"
#include "misc.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	if (argc != 2) {
		fprintf(stderr, "Usage: sim_host.elf <Path-to-sim-hex-file>\n");
		return 1;
	}

	CPU<Vsalaga_chip>* core = new CPU<Vsalaga_chip>(10000,
						  true,
						  false);

	core->load_cache(I_CACHE, CACHE_SIZE/4, argv[1]);
	core->load_cache(D_CACHE, CACHE_SIZE/4, argv[1]);

	core->open_trace("salaga_chip_sim.vcd");
	core->reset();

	while(!core->done()) {
		core->tick();
	}

	core->close_trace();

	delete core;

	return 0;
}
