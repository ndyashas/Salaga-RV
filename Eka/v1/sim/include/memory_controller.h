/*
 * A separate memory handler class is used for future situations
 * where I'll have simulate some cache-misses and stall the processor.
 */

#include <stdlib.h>

#ifndef __EKA_V1_MEM_HANDLER__
#define __EKA_V1_MEM_HANDLER__

class Memory_controller
{
private:
	unsigned int* l1_inst_cache;
	unsigned int* l1_data_cache;
	bool internal_inst_cache_initialized;
	bool internal_data_cache_initialized;

public:

	Memory_controller(unsigned int* l1_inst_cache = NULL,
			  unsigned int* l1_data_cache = NULL);
	~Memory_controller(void);

	bool l1_inst_cache_access(unsigned int inst_addr,
				  unsigned int& instruction);
	bool l1_data_cache_access(unsigned int data_addr,
				  unsigned int& mem_rd_data);
	bool l1_data_cache_update(unsigned int data_addr,
				  unsigned int mem_wr_data);
};

#endif
