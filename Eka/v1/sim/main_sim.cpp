#include <iostream>
#include <stdlib.h>
#include "Veka_core_v1.h"
#include "verilated.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);	
	Veka_core_v1 *core = new Veka_core_v1;

	int i = 0;
	// Reset for 5 clock cycles
	while(i < 5) {
		core->clk = i%2;
		core->resetb = 0;
		core->eval();
		++i;
	}
	core->resetb = 1;
	core->eval();
	
	// Execute for 20 clock cycles
	while(i < 25) {
		core->clk = i%2;
		core->eval();
		++i;
	}
	
	return 0;
}

	
