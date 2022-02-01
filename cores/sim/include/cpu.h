/* This file is greatly inspired by the blog post by http://zipcpu.com/about .
 * Details and further explanantions can be found at:
 *
 * https://zipcpu.com/blog/2017/06/21/looking-at-verilator.html
 */


#include <iostream>
#include <fstream>
#include <stdlib.h>
#include "verilated.h"
#include <verilated_vcd_c.h>
#include "Vsalaga_chip.h"
#include "Vsalaga_chip___024root.h"
#include "misc.h"


#ifndef __SALAGA_CORE__
#define __SALAGA_CORE__

template<class CPU_mod>
class CPU {

private:
	unsigned long int tick_count;
	unsigned long int total_sim_ticks;
	VerilatedVcdC *tracer;
	bool trace;
	bool debug_print;
	void __update_access_buffer();

public:
	CPU_mod *cpu_mod;
	/* Set 'total_sim_ticks' to 0 for unbound simulation till
	 * 'Ctrl + C' is pressed.
	 */
	uint32_t* access_buffer;

	CPU(unsigned long int total_sim_ticks = 100,
	    // Memory_controller* memory_controller = NULL,
	    bool trace = true,
	    bool debug_print = true);
	~CPU(void);

	void reset(void);
	void tick(void);
	void open_trace(const char *vcd_file_name);
	void close_trace(void);
	bool done(void);
	void load_cache(int cache_type,
			unsigned long int l1_cache_size_in_words,
			const char* hex_file_path);
};

template<class CPU_mod>
CPU<CPU_mod>::CPU(unsigned long int total_sim_ticks,
		  bool trace,
		  bool debug_print)
{
	this->cpu_mod = new CPU_mod();
	this->tick_count = 0l;
	this->total_sim_ticks = total_sim_ticks;
	if (!total_sim_ticks) {
		std::cout
			<< "'Ctrl + C' to exit simulation"
			<< std::endl;
	}
	this->trace = trace;
	if (trace) {
		Verilated::traceEverOn(true);
	}
	this->tracer = NULL;
	this->debug_print = debug_print;

	this->access_buffer = new uint32_t[512];
}

template<class CPU_mod>
CPU<CPU_mod>::~CPU(void)
{
	delete this->cpu_mod;
	delete[] this->access_buffer;
	this->cpu_mod = NULL;
}

template<class CPU_mod>
void CPU<CPU_mod>::reset(void)
{
	this->cpu_mod->reset = 1;
	this->tick();
	this->cpu_mod->reset = 0;
}

template<class CPU_mod>
void CPU<CPU_mod>::tick(void)
{
	this->tick_count++;

	this->cpu_mod->clk = 0;
	this->cpu_mod->eval();

	if (this->trace && this->tracer) this->tracer->dump(10*this->tick_count-1);

	this->cpu_mod->clk = 1;
	this->cpu_mod->eval();

	if (this->trace && this->tracer) this->tracer->dump(10*this->tick_count);

	this->cpu_mod->clk = 0;
	this->cpu_mod->eval();

	this->__update_access_buffer();

	if (this->trace && this->tracer) {
		this->tracer->dump(10*this->tick_count+5);
	        this->tracer->flush();
	}
}

template<class CPU_mod>
void CPU<CPU_mod>::open_trace(const char *vcd_file_name)
{
	if (this->trace) {
		if (this->tracer) {
			delete this->tracer;
			this->tracer = NULL;
		}

		this->tracer = new VerilatedVcdC;
		this->cpu_mod->trace(this->tracer, 99);
		this->tracer->open(vcd_file_name);
	}
}

template<class CPU_mod>
void CPU<CPU_mod>::close_trace(void)
{
	if (this->trace) {
		if (this->tracer) {
			this->tracer->close();
			delete this->tracer;
			this->tracer = NULL;
		}
	}
}

template<class CPU_mod>
bool CPU<CPU_mod>::done(void)
{
	return (Verilated::gotFinish()
		|| ((this->total_sim_ticks != 0) && (this->tick_count >= this->total_sim_ticks)));
}

template<class CPU_mod>
void CPU<CPU_mod>::load_cache(int cache_type,
			      unsigned long int l1_cache_size_in_words,
			      const char* hex_file_path)
{
	unsigned long int i;
	uint32_t word;
	std::ifstream hex_file(hex_file_path);

	i = 0;
	while((i < (int)(CACHE_SIZE/4)) && (hex_file >> std::hex >> word)) {
		if (cache_type == I_CACHE) {
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_3[i]   = (word & 0xff000000) >> 24;
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_2[i]   = (word & 0x00ff0000) >> 16;
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_1[i]   = (word & 0x0000ff00) >> 8;
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_inst_cache__DOT__l1_memory_bank_0[i++] = (word & 0x000000ff);
		}
		else if (cache_type == D_CACHE) {
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_3[i]   = (word & 0xff000000) >> 24;
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_2[i]   = (word & 0x00ff0000) >> 16;
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_1[i]   = (word & 0x0000ff00) >> 8;
		        this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_0[i++] = (word & 0x000000ff);
		}
	}

	hex_file.close();
}


template<class CPU_mod>
void CPU<CPU_mod>::__update_access_buffer()
{
	int i;

	for(i = 0; i < 512; ++i) {
		this->access_buffer[i] = 0;
		this->access_buffer[i] = (this->access_buffer[i]
					  | ((this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_3[2048+i] << 24) & 0xff000000));
		this->access_buffer[i] = (this->access_buffer[i]
					  | ((this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_2[2048+i] << 16) & 0x00ff0000));
		this->access_buffer[i] = (this->access_buffer[i]
					  | ((this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_1[2048+i] <<  8) & 0x0000ff00));
		this->access_buffer[i] = (this->access_buffer[i]
					  | (this->cpu_mod->rootp->salaga_chip__DOT__l1_data_cache__DOT__l1_memory_bank_0[2048+i] & 0x000000ff));
	}
}
#endif
