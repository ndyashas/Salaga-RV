#include <iostream>
#include <fstream>
#include <stdlib.h>
#include "verilated.h"
#include "Vsalaga_chip.h"
#include "Vsalaga_chip___024root.h"
#include "cpu.h"
#include "misc.h"

void load_cache(CPU<Vsalaga_chip>* core,
		int cache_type,
		unsigned long int l1_cache_size_in_words,
		const char* hex_file_path);


int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	if (argc != 2) {
		fprintf(stderr, "Usage: sim_host.elf <Path-to-sim-hex-file>\n");
		return 1;
	}

	CPU<Vsalaga_chip>* core = new CPU<Vsalaga_chip>(2000,
						  true,
						  false);

	load_cache(core, I_CACHE, CACHE_SIZE/4, argv[1]);
	load_cache(core, D_CACHE, CACHE_SIZE/4, argv[1]);

	core->open_trace("salaga_chip_sim.vcd");
	core->reset();
	while(!core->done()) {
		core->tick();
	}
	core->close_trace();

	delete core;

	return 0;
}

	
void load_cache(CPU<Vsalaga_chip>* core,
		int cache_type,
		unsigned long int l1_cache_size_in_words,
		const char* hex_file_path)
{
	unsigned long int i;
	unsigned int word;
	std::ifstream hex_file(hex_file_path);

	i = 0;
	while((i < (int)(CACHE_SIZE/4)) && (hex_file >> std::hex >> word)) {
		if (cache_type == I_CACHE) {
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_3[i]   = (word & 0xff000000) >> 24;
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_2[i]   = (word & 0x00ff0000) >> 16;
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_1[i]   = (word & 0x0000ff00) >> 8;
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_0[i++] = (word & 0x000000ff);
		}
		else if (cache_type == D_CACHE) {
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_3[i]   = (word & 0xff000000) >> 24;
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_2[i]   = (word & 0x00ff0000) >> 16;
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_1[i]   = (word & 0x0000ff00) >> 8;
		        core->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_0[i++] = (word & 0x000000ff);
		}
	}

	hex_file.close();
}
