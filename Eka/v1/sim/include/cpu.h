/* This file is greatly inspired by the blog post by http://zipcpu.com/about .
 * Details and further explanantions can be found at:
 *
 * https://zipcpu.com/blog/2017/06/21/looking-at-verilator.html
 */


#include <iostream>
#include <stdlib.h>
#include "verilated.h"

template<class CPU_mod>
class CPU {
	unsigned long int tick_count;
	unsigned long int total_sim_ticks;
	CPU_mod *cpu_mod;

public:
	CPU(unsigned long int total_sim_ticks = 100);
	~CPU(void);

	void reset(void);
	void tick(void);
	bool done(void);
};

template<class CPU_mod>
CPU<CPU_mod>::CPU(unsigned long int total_sim_ticks)
{
	this->cpu_mod = new CPU_mod;
	this->tick_count = 0l;
	this->total_sim_ticks = total_sim_ticks;
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
void CPU<CPU_mod>::tick(void)
{
	this->tick_count++;

	this->cpu_mod->clk = 0;
	this->cpu_mod->eval();
	this->cpu_mod->clk = 1;
	this->cpu_mod->eval();
	this->cpu_mod->clk = 0;
	this->cpu_mod->eval();
}

template<class CPU_mod>
bool CPU<CPU_mod>::done(void)
{
	return (Verilated::gotFinish()
		|| (this->tick_count >= this->total_sim_ticks));
}
