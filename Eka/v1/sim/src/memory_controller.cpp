#include <stdlib.h>
#include "memory_controller.h"

Memory_controller::Memory_controller(unsigned int* l1_inst_cache,
				     unsigned int* l1_data_cache)
{
	this->internal_inst_cache_initialized = false;
	this->internal_data_cache_initialized = false;

	if (l1_inst_cache) this->l1_inst_cache = l1_inst_cache;
	else {
		this->internal_inst_cache_initialized = true;
		this->l1_inst_cache = new unsigned int[1024]{15};
	}

	if (l1_data_cache) this->l1_data_cache = l1_data_cache;
	else {
		this->internal_data_cache_initialized = true;
		this->l1_data_cache = new unsigned int[4096]{3};
	}
}

Memory_controller::~Memory_controller(void)
{
	if (this->internal_inst_cache_initialized) {
		delete[] this->l1_inst_cache;
		this->l1_inst_cache = NULL;
	}

	if (this->internal_data_cache_initialized) {
		delete[] this->l1_data_cache;
		this->l1_data_cache = NULL;
	}
}

bool Memory_controller::l1_inst_cache_access(unsigned int inst_addr,
					     unsigned int& instruction)
{
	if (this->l1_inst_cache) {
		/* TODO : memory access check */
		instruction = this->l1_inst_cache[inst_addr/4];
	}

	return false;
}

bool Memory_controller::l1_data_cache_access(unsigned int data_addr,
					     unsigned int& mem_rd_data)
{
	if (this->l1_data_cache) {
		/* TODO : memory access check */
		mem_rd_data = this->l1_data_cache[data_addr/4];
	}

	return false;
}

bool Memory_controller::l1_data_cache_update(unsigned int data_addr,
					     unsigned int mem_wr_data)
{
	if (this->l1_data_cache) {
		/* TODO : memory access check */
		this->l1_data_cache[data_addr/4] = mem_wr_data;
	}

	return false;
}
