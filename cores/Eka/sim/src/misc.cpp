#include <iostream>
#include <fstream>
#include "misc.h"

void load_i_cache(unsigned int* l1_inst_cache,
		  unsigned long int l1_inst_cache_size_in_words,
		  const char* hex_file_path)
{
	unsigned long int i;
	unsigned int inst;
	std::ifstream hex_file(hex_file_path);

	i = 0;
	while(hex_file >> std::hex >> inst) {
		l1_inst_cache[i++] = inst;
	}

	hex_file.close();
}
