/* This file is greatly inspired by the blog post by http://zipcpu.com/about .
 * Details and further explanantions can be found at:
 *
 * https://zipcpu.com/blog/2017/06/21/looking-at-verilator.html
 */


#include <iostream>
#include <stdlib.h>
#include "verilated.h"
#include <verilated_vcd_c.h>

#ifndef __EKA_V1_CORE__
#define __EKA_V1_CORE__

template<class CPU_mod>
class CPU {

private:
	unsigned long int tick_count;
	unsigned long int total_sim_ticks;
	CPU_mod *cpu_mod;
	VerilatedVcdC *tracer;
	bool trace;
	bool debug_print;
	unsigned int inst_addr;
	unsigned int data_addr;
	unsigned int mem_wr_data;
	unsigned short int mem_wr;
	unsigned short int mem_rd;

	void mem_wr_handler(void);
	void mem_rd_handler(void);
	void inst_handler(void);

public:
	/* Set 'total_sim_ticks' to 0 for unbound simulation till
	 * 'Ctrl + C' is pressed.
	 */
	CPU(unsigned long int total_sim_ticks = 100,
	    bool trace = true,
	    bool debug_print = true);
	~CPU(void);

	void reset(void);
	void tick(void);
	void open_trace(const char *vcd_file_name);
	void close_trace(void);
	bool done(void);
};

template<class CPU_mod>
CPU<CPU_mod>::CPU(unsigned long int total_sim_ticks, bool trace, bool debug_print)
{
	this->cpu_mod = new CPU_mod;
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
	this->debug_print = debug_print;
}

template<class CPU_mod>
CPU<CPU_mod>::~CPU(void)
{
	delete this->cpu_mod;
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
void CPU<CPU_mod>::mem_wr_handler(void)
{
}

template<class CPU_mod>
void CPU<CPU_mod>::mem_rd_handler(void)
{
}

template<class CPU_mod>
void CPU<CPU_mod>::inst_handler(void)
{
}

template<class CPU_mod>
void CPU<CPU_mod>::tick(void)
{
	this->tick_count++;

	this->cpu_mod->clk = 0;
	this->cpu_mod->eval();

	if (this->debug_print) {
		printf("Data addr: 0x%08x\n",
		       this->cpu_mod->data_addr);
		printf("Inst addr: 0x%08x\n",
		       this->cpu_mod->inst_addr);
	}

	// Read the outputs from the processor here
	this->mem_rd = this->cpu_mod->mem_rd;
	this->mem_wr = this->cpu_mod->mem_wr;
	this->inst_addr = this->cpu_mod->inst_addr;
	this->data_addr = this->cpu_mod->data_addr;
	this->mem_wr_data = this->cpu_mod->mem_wr_data;

	if (this->trace && this->tracer) tracer->dump(10*this->tick_count-1);

	this->cpu_mod->clk = 1;
	this->cpu_mod->eval();

	// Apply the data/instruction inputs here
	// Uses 'data_addr'
	if (this->mem_wr) {
		// Uses 'mem_wr_data'
		this->mem_wr_handler();
	}

	if (this->mem_rd) {
		// Populates 'this->cpu_mod->mem_rd_data'
		this->mem_rd_handler();
	}

	// Uses 'inst_addr' and populates 'this->cpu_mod->instruction'
	this->inst_handler();

	if (this->trace && this->tracer) tracer->dump(10*this->tick_count);

	this->cpu_mod->clk = 0;
	this->cpu_mod->eval();

	if (this->trace && this->tracer) {
		tracer->dump(10*this->tick_count+5);
		tracer->flush();
	}
}

template<class CPU_mod>
void CPU<CPU_mod>::open_trace(const char *vcd_file_name)
{
	if (this->trace) {
		if (!tracer) {
			this->tracer = new VerilatedVcdC;
			this->cpu_mod->trace(this->tracer, 99);
			this->tracer->open(vcd_file_name);
		}
		else {
			std::cout
				<< "Unable to initialize tracing, VCD file will NOT be generated"
				<< std::endl;
		}
	}
}

template<class CPU_mod>
void CPU<CPU_mod>::close_trace(void)
{
	if (this->trace) {
		if (tracer) {
			tracer->close();
			tracer = NULL;
		}
	}
}


template<class CPU_mod>
bool CPU<CPU_mod>::done(void)
{
	return (Verilated::gotFinish()
		|| ((this->total_sim_ticks != 0) && (this->tick_count >= this->total_sim_ticks)));
}

#endif
