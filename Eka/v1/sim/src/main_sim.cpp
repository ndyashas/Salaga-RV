#include <iostream>
#include <stdlib.h>
#include "Veka_core_v1.h"
#include "verilated.h"
#include "cpu.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);	

	CPU<Veka_core_v1> *core = new CPU<Veka_core_v1>(100);
	
	while(!core->done()) {
		core->tick();
	}

	return 0;
}

	
