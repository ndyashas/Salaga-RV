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
	l1_inst_cache[1]  = 0b00000000010100000000000010010011; // ADDI rd(1) rs1(0) 5
	l1_inst_cache[2]  = 0b00000000011100000000000100010011; // ADDI rd(2) rs1(0) 7
	l1_inst_cache[3]  = 0b01000000001000001000000110110011; // SUB rd(3) rs1(1) rs2(2)
	l1_inst_cache[4]  = 0b00000000001100000010011000100011; // SW rs2(3) rs1(0) 12

	l1_inst_cache[5]  = 0b00000000000000001001101001100011; // BNE rs1(1) rs2(0) 20 // 5*4 = 20 bytes. Jump to Cache[10] inst
	l1_inst_cache[6]  = 0b00000000000000000000000000000000;
	l1_inst_cache[7]  = 0b00000000000000000000000000000000;
	l1_inst_cache[8]  = 0b00000000000000000000000000000000;
	l1_inst_cache[9]  = 0b00000000000000000000000000000000;

	l1_inst_cache[10] = 0b00000001100000000010001010000011; // LW rd(5) rs1(0) 24  // holds 3
	l1_inst_cache[11] = 0b00000000110000000010001100000011; // LW rd(6) rs1(0) 12  // holds -2
	l1_inst_cache[12] = 0b00000000011000101000001110110011; // ADD rd(7) rs1(5) rs2(6)
	l1_inst_cache[13] = 0b00000010011100000010000000100011; // SW rs2(7) rs1(0) 32 // expect 1
	l1_inst_cache[14] = 0b00000000011100110000000000010011; // NOP

	l1_inst_cache[15] = 0b00000000000000000001010010110111; // LUI rd(9)  1
	l1_inst_cache[16] = 0b00000000000000000010010100110111; // LUI rd(10) 2
	l1_inst_cache[17] = 0b00000000101001001000010110110011; // ADD rd(11) rs1(9) rs2(10)
	l1_inst_cache[18] = 0b00000010101100000010001000100011; // SW rs2(11) rs1(0) 36 //
	l1_inst_cache[19] = 0b00000000000000000000000000000000;

	unsigned int* l1_data_cache = new unsigned int[4096];

	l1_data_cache[6]  = 0b00000000000000000000000000000011;

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

	core->print_Regfile();
	memory_controller->l1_inst_cache_print(20);
	memory_controller->l1_data_cache_print(16);

	delete memory_controller;
	delete core;
	delete[] l1_inst_cache;
	delete[] l1_data_cache;
	return 0;
}

	
