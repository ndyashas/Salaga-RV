#ifndef __SLG_MISC__
#define __SLG_MISC__

#include "verilated.h"
#include "Veka_chip.h"
#include "Veka_chip___024root.h"
#include "cpu.h"

#define CACHE_SIZE 4 * 128
#define I_CACHE    0
#define D_CACHE    1

/* Loads instruction/data cache buffer with the hex contents of target program
 */
void load_cache(CPU<Veka_chip>* core,
		int cache_type,
		unsigned long int l1_cache_size_in_words,
		const char* hex_file_path);

#endif
