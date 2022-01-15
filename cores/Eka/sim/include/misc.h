#ifndef __SLG_MISC__
#define __SLG_MISC__

/* Loads the instruction cache buffer with the hex contents of target program
 */
void load_i_cache(unsigned int* l1_inst_cache,
		  unsigned long int l1_inst_cache_size_in_words,
		  const char* hex_file_path);

#endif
