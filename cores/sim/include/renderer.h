/*
 * This is a simple class which reads in a framebuffer from D_Cache
 * and displays it on the host machine using SDL library
 * Motivation by
 *
 * Will Green -
 * https://projectf.io/posts/verilog-sim-verilator-sdl/
 *
 */

#ifndef __SALAGA_RENDERER__
#define __SALAGA_RENDERER__

#include <iostream>
#include <stdlib.h>
#include "cpu.h"

class Renderer {

public:
        Renderer();
	~Renderer();
};

#endif
