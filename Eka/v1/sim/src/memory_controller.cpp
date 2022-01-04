#include <iostream>
#include <stdlib.h>
#include "memory_controller.h"

Memory_controller::Memory_controller(unsigned int* l1_inst_cache,
				     unsigned long int l1_inst_cache_size,
				     unsigned int* l1_data_cache,
				     unsigned long int l1_data_cache_size)
{
	this->internal_inst_cache_initialized = false;
	this->internal_data_cache_initialized = false;

	if (l1_inst_cache) {
		this->l1_inst_cache = l1_inst_cache;
		this->l1_inst_cache_size = l1_inst_cache_size;
	}
	else {
		this->internal_inst_cache_initialized = true;
		this->l1_inst_cache = new unsigned int[1024]{15};
		this->l1_inst_cache_size = 1024/4;
	}

	if (l1_data_cache) {
		this->l1_data_cache = l1_data_cache;
		this->l1_data_cache_size = l1_data_cache_size;
	}
	else {
		this->internal_data_cache_initialized = true;
		this->l1_data_cache = new unsigned int[4096]{3};
		this->l1_data_cache_size = 4096/4;
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

void Memory_controller::l1_inst_cache_print(unsigned long int size)
{
	int i;
	unsigned int word;
	unsigned int size_by_four;
	if (this->l1_inst_cache) {
		if (size >= this->l1_inst_cache_size)
			size = this->l1_inst_cache_size;

		size_by_four = size / 4;
	        printf("Instruction memory:\n");
		for (i = 0; i < size_by_four; ++i) {
			word = this->l1_inst_cache[i];
			printf("%02x %02x %02x %02x - Byte %05d\n",
			       (word & 0xff000000) >> 24,
			       (word & 0x00ff0000) >> 16,
			       (word & 0x0000ff00) >> 8,
			       (word & 0x000000ff),
			       i*4);
		}
	        printf("\n");
	}
}

void Memory_controller::l1_data_cache_print(unsigned long int size)
{
	int i;
	unsigned int word;
	unsigned int size_by_four;
	if (this->l1_data_cache) {
		if (size >= this->l1_data_cache_size)
			size = this->l1_data_cache_size;

		size_by_four = size / 4;
	        printf("Data memory:\n");
		for (i = 0; i < size_by_four; ++i) {
			word = this->l1_data_cache[i];
			printf("%02x %02x %02x %02x - Byte %05d\n",
			       (word & 0xff000000) >> 24,
			       (word & 0x00ff0000) >> 16,
			       (word & 0x0000ff00) >> 8,
			       (word & 0x000000ff),
			       i*4);
		}
	        printf("\n");
	}
}
