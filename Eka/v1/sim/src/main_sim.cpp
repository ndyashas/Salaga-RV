#include <iostream>
#include <stdlib.h>
#include "Veka_core_v1.h"
#include "verilated.h"
#include "cpu.h"
#include "memory_controller.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	unsigned int* l1_inst_cache = new unsigned int[1024];

	l1_inst_cache[0]  = 0b00000000000000000000000000000000;
	l1_inst_cache[1]  = 0b00000000101000000010000010000011; // LW rd(1) rs1(0) 10
	l1_inst_cache[2]  = 0b00000000101100000010000100000000; // LW rd(2) rs1(0) 11
	l1_inst_cache[3]  = 0b00000000001000001000000110110011; // ADD rd(3) rs1(1) rs1(2)
	l1_inst_cache[4]  = 0b00000000000000011010011000100011; // SW rs1(3) rs2(0) 12

	unsigned int* l1_data_cache = new unsigned int[4096];

	l1_data_cache[9]  = 0b00000000000000000000000000000101; // 5
	l1_data_cache[10] = 0b00000000000000000000000000000111; // 7
	l1_data_cache[11] = 0b00000000000000000000000000000000; // expect 12
	
	Memory_controller* memory_controller = new Memory_controller(l1_inst_cache,
								     1024/4,
								     l1_data_cache,
								     4096/4);

	CPU<Veka_core_v1>* core = new CPU<Veka_core_v1>(100,
							memory_controller,
							true,
						        false);
	core->open_trace("eka_core_v1_sim.vcd");

	core->reset();
	while(!core->done()) {
		core->tick();
	}
	core->close_trace();

	memory_controller->l1_inst_cache_print(32);
	memory_controller->l1_data_cache_print(64);

	delete memory_controller;
	delete core;
	delete[] l1_inst_cache;
	delete[] l1_data_cache;
	return 0;
}

	
