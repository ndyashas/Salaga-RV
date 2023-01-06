#include <iostream>
#include <fstream>
#include <stdlib.h>
#include "salaga_display.h"
#include "verilated.h"
#include "Vtb.h"

#define SIM_DISPLAY_UPDATE_RATIO 10000

unsigned long int simtime = 0;

double sc_time_stamp() { return simtime; }

void tick(Vtb * &Vtb)
{
    simtime++;    
    Vtb->clk = 0;
    Vtb->eval();
    
    simtime++;    
    Vtb->clk = 1;
    Vtb->eval();

    simtime++;
    Vtb->clk = 0;
    Vtb->eval();
}


int main(int argc, char **argv)
{
    unsigned int counter = 0;
    Verilated::commandArgs(argc, argv);

#ifdef VERILATOR_WAVE_TRACE
    Verilated::traceEverOn(true);
#endif

    Salaga_Sim_Display sd_obj;
    
    Vtb *tb = new Vtb;
    
    // Reset
    tb->reset = 1;
    // simtime
    tick(tb);
    tick(tb);
    tb->reset = 0;	
    
    while (!Verilated::gotFinish() && !sd_obj.got_quit()) {
	tick(tb);
	sd_obj.process_input(tb->disp_en & 1, tb->disp_DC & 1, tb->disp_bus & 0xffffff);
	if (counter++ % SIM_DISPLAY_UPDATE_RATIO == 0) {
	    sd_obj.draw();
	    //sd_obj.debug();
	}
    }
    
    return 0;
}
