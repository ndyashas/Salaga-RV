#include <iostream>
#include <stdlib.h>
#include "memory_controller.h"

Memory_controller::Memory_controller(unsigned int* l1_inst_cache,
				     unsigned long int l1_inst_cache_size_in_words,
				     unsigned int* l1_data_cache,
				     unsigned long int l1_data_cache_size_in_words)
{
	this->internal_inst_cache_initialized = false;
	this->internal_data_cache_initialized = false;

	if (l1_inst_cache) {
		this->l1_inst_cache = l1_inst_cache;
		this->l1_inst_cache_size_in_words = l1_inst_cache_size_in_words;
	}
	else {
		this->internal_inst_cache_initialized = true;
		this->l1_inst_cache = new unsigned int[1024]{15};
		this->l1_inst_cache_size_in_words = 1024/4;
	}

	if (l1_data_cache) {
		this->l1_data_cache = l1_data_cache;
		this->l1_data_cache_size_in_words = l1_data_cache_size_in_words;
	}
	else {
		this->internal_data_cache_initialized = true;
		this->l1_data_cache = new unsigned int[4096]{3};
		this->l1_data_cache_size_in_words = 4096/4;
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
		if (inst_addr/4 < this->l1_inst_cache_size_in_words) {
			instruction = this->l1_inst_cache[inst_addr/4];
		}
		else {
		        printf("Instruction address out of bound:\n");
			printf("Instruction requested : 0x%08x\n", inst_addr * 4);
		        printf("Memory size           : 0x%08lx\n", this->l1_inst_cache_size_in_words * 4);
		}
	}

	return false;
}

bool Memory_controller::l1_data_cache_access(unsigned int data_addr,
					     unsigned int& mem_rd_data)
{
	if (this->l1_data_cache) {
		if (data_addr/4 < this->l1_data_cache_size_in_words) {
		        mem_rd_data = this->l1_data_cache[data_addr/4];
		}
		else {
		        printf("Data address out of bound:\n");
			printf("Data requested : 0x%08x\n", data_addr * 4);
		        printf("Memory size    : 0x%08lx\n", this->l1_data_cache_size_in_words * 4);
		}
	}

	return false;
}

bool Memory_controller::l1_data_cache_update(unsigned int data_addr,
					     unsigned int mem_wr_data,
					     unsigned short int mem_wr_mask)
{
	if (this->l1_data_cache) {
		if (data_addr/4 < this->l1_data_cache_size_in_words) {
			// depending on the mask, we will have to update
			// the memory.
			if ((mem_wr_mask & 0x1) == 0x1)
				this->l1_data_cache[data_addr/4] = (this->l1_data_cache[data_addr/4] & 0xffffff00) | (mem_wr_data & 0x000000ff);
			if ((mem_wr_mask & 0x2) == 0x2)
				this->l1_data_cache[data_addr/4] = (this->l1_data_cache[data_addr/4] & 0xffff00ff) | (mem_wr_data & 0x0000ff00);
			if ((mem_wr_mask & 0x4) == 0x4)
				this->l1_data_cache[data_addr/4] = (this->l1_data_cache[data_addr/4] & 0xff00ffff) | (mem_wr_data & 0x00ff0000);
			if ((mem_wr_mask & 0x8) == 0x8)
				this->l1_data_cache[data_addr/4] = (this->l1_data_cache[data_addr/4] & 0x00ffffff) | (mem_wr_data & 0xff000000);
		}
		else {
		        printf("Data address out of bound:\n");
			printf("Data requested : 0x%08x\n", data_addr * 4);
		        printf("Memory size    : 0x%08lx\n", this->l1_data_cache_size_in_words * 4);
		}
	}

	return false;
}

void Memory_controller::l1_inst_cache_print(unsigned long int size_in_words)
{
	int i;
	unsigned int word;
	if (this->l1_inst_cache) {
		if (size_in_words >= this->l1_inst_cache_size_in_words)
			size_in_words = this->l1_inst_cache_size_in_words;

	        printf("Instruction memory:\n");
		for (i = 0; i < size_in_words; ++i) {
			word = this->l1_inst_cache[i];
			printf("%02x %02x %02x %02x - Byte %08x\n",
			       (word & 0xff000000) >> 24,
			       (word & 0x00ff0000) >> 16,
			       (word & 0x0000ff00) >> 8,
			       (word & 0x000000ff),
			       i*4);
		}
	        printf("\n");
	}
}

void Memory_controller::l1_data_cache_print(unsigned long int size_in_words)
{
	int i;
	unsigned int word;
	if (this->l1_data_cache) {
		if (size_in_words >= this->l1_data_cache_size_in_words)
			size_in_words = this->l1_data_cache_size_in_words;

	        printf("Data memory:\n");
		for (i = 0; i < size_in_words; ++i) {
			word = this->l1_data_cache[i];
			printf("%02x %02x %02x %02x - Byte %08x\n",
			       (word & 0xff000000) >> 24,
			       (word & 0x00ff0000) >> 16,
			       (word & 0x0000ff00) >> 8,
			       (word & 0x000000ff),
			       i*4);
		}
	        printf("\n");
	}
}
