#include <iostream>
#include <fstream>
#include "misc.h"
#include "verilated.h"
#include "Veka_chip.h"
#include "cpu.h"

void load_cache(CPU<Veka_chip>* core,
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
		        core->cpu_mod->rootp->eka_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_3[i]   = (word & 0xff000000) >> 24;
		        core->cpu_mod->rootp->eka_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_2[i]   = (word & 0x00ff0000) >> 16;
		        core->cpu_mod->rootp->eka_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_1[i]   = (word & 0x0000ff00) >> 8;
		        core->cpu_mod->rootp->eka_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_0[i++] = (word & 0x000000ff);
		}
		else if (cache_type == D_CACHE) {
		        core->cpu_mod->rootp->eka_chip__DOT__l1_data_cache__DOT__l1_memory_bank_3[i]   = (word & 0xff000000) >> 24;
		        core->cpu_mod->rootp->eka_chip__DOT__l1_data_cache__DOT__l1_memory_bank_2[i]   = (word & 0x00ff0000) >> 16;
		        core->cpu_mod->rootp->eka_chip__DOT__l1_data_cache__DOT__l1_memory_bank_1[i]   = (word & 0x0000ff00) >> 8;
		        core->cpu_mod->rootp->eka_chip__DOT__l1_data_cache__DOT__l1_memory_bank_0[i++] = (word & 0x000000ff);
		}
	}

	hex_file.close();
}
