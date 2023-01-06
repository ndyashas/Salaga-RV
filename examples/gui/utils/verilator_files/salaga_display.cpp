#include "salaga_display.h"
#include <SDL.h>
#include <iostream>

Salaga_Sim_Display::Salaga_Sim_Display()
{
    // Initialize 'display_buffer'
    display_buffer_ = new struct Pixel[SIM_DISPLAY_HEIGHT * SIM_DISPLAY_WIDTH];

    // Following code inspired by Project-F - https://projectf.io/posts/verilog-sim-verilator-sdl/
    sdl_window_ = SDL_CreateWindow("Salaga Display", SDL_WINDOWPOS_CENTERED,
				  SDL_WINDOWPOS_CENTERED, SIM_DISPLAY_WIDTH, SIM_DISPLAY_HEIGHT, SDL_WINDOW_SHOWN);
    if (!sdl_window_) {
	printf("Window creation failed: %s\n", SDL_GetError());
	std::exit(1);
    }

    sdl_renderer_ = SDL_CreateRenderer(sdl_window_, -1,
				      SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!sdl_renderer_) {
        printf("Renderer creation failed: %s\n", SDL_GetError());
	std::exit(1);
    }

    sdl_texture_ = SDL_CreateTexture(sdl_renderer_, SDL_PIXELFORMAT_RGBA8888,
				    SDL_TEXTUREACCESS_TARGET, SIM_DISPLAY_WIDTH, SIM_DISPLAY_HEIGHT);
    if (!sdl_texture_) {
        printf("Texture creation failed: %s\n", SDL_GetError());
	std::exit(1);
    }
}

bool Salaga_Sim_Display::got_quit()
{
    if (SDL_PollEvent(&e_)) {
	if (e_.type == SDL_QUIT) {
	    return true;
	}
    }
    return false;
}

Salaga_Sim_Display::~Salaga_Sim_Display()
{
    delete[] this->display_buffer_;

    SDL_DestroyTexture(sdl_texture_);
    SDL_DestroyRenderer(sdl_renderer_);
    SDL_DestroyWindow(sdl_window_);
    SDL_Quit();
}

void Salaga_Sim_Display::draw()
{
    SDL_UpdateTexture(sdl_texture_, NULL, display_buffer_, SIM_DISPLAY_WIDTH*sizeof(Pixel));
    SDL_RenderClear(sdl_renderer_);
    SDL_RenderCopy(sdl_renderer_, sdl_texture_, NULL, NULL);
    SDL_RenderPresent(sdl_renderer_);
}

void Salaga_Sim_Display::debug()
{
    int i, j;
    for (i = 0; i < SIM_DISPLAY_WIDTH; ++i) {
	for (j = 0; j < SIM_DISPLAY_HEIGHT; ++j) {
	    Pixel *pixel = &display_buffer_[i * SIM_DISPLAY_WIDTH + j];
	    // std::cout << (int)pixel->r << " " << (int)pixel->g << " " << (int)pixel->b << " | ";
	}
	// std::cout << "LINE END" << std::endl;
    }
    // std::cout << "DONE" << std::endl;
    // std::cout << "DONE" << std::endl;
}

void Salaga_Sim_Display::set_col_ptr(int col_ptr_start, int col_ptr_end)
{
    curr_col_start_ = col_ptr_start;
    curr_col_end_   = col_ptr_end;

    curr_col_ptr_   = col_ptr_start;
}

void Salaga_Sim_Display::set_row_ptr(int row_ptr_start, int row_ptr_end)
{
    curr_row_start_ = row_ptr_start;
    curr_row_end_   = row_ptr_end;

    curr_row_ptr_   = row_ptr_start;
}

void Salaga_Sim_Display::put_color(unsigned int color_24bit_rgb)
{
    // Apply color to the specific pixel and move cursor to the next pixel
    Pixel *pixel = &display_buffer_[curr_row_ptr_ * SIM_DISPLAY_WIDTH + curr_col_ptr_];
    pixel->a = 0;
    pixel->r = (color_24bit_rgb & 0xff0000) >> 16;
    pixel->g = (color_24bit_rgb & 0x00ff00) >> 8;
    pixel->b = (color_24bit_rgb & 0x0000ff);

    // std::cout << "col ptr: " << curr_col_ptr_ << std::endl;
    // std::cout << "row ptr: " << curr_row_ptr_ << std::endl;
    // std::cout << "r: " << (int)pixel->r << std::endl;
    // std::cout << "g: " << (int)pixel->g << std::endl;
    // std::cout << "b: " << (int)pixel->b << std::endl;
    
    // Update curr ptr
    if (curr_col_ptr_ == curr_col_end_) {
	curr_col_ptr_ = curr_col_start_;
	if (curr_row_ptr_ == curr_row_end_) {
	    curr_row_ptr_ = curr_row_start_;
	}
	else {
	    ++curr_row_ptr_;
	}
    }
    else {
	++curr_col_ptr_;
    }
}

void Salaga_Sim_Display::process_input(int disp_en, int disp_DC, int disp_bus)
{
    int bus_data;

    if (disp_en) {
	if (disp_DC) { // Command
	    // LSB 4 bits encode the command
	    switch(disp_bus & 0xf) {
	    case 0: // Set column range
		// std::cout << "Command to set column range " << ((disp_bus & 0xffc000) >> 14) << " " << ((disp_bus & 0x3ff0) >> 4) << std::endl;
		set_col_ptr((disp_bus & 0xffc000) >> 14, (disp_bus & 0x3ff0) >> 4);
		break;
	    case 1: // Set row range
		// std::cout << "Command to set row range " << ((disp_bus & 0xffc000) >> 14) << " " << ((disp_bus & 0x3ff0) >> 4) << std::endl;
		set_row_ptr((disp_bus & 0xffc000) >> 14, (disp_bus & 0x3ff0) >> 4);
		break;
	    default:
		break;
	    }
	}
	else {         // Data
	    // std::cout << "Command to print color" << std::endl;
	    put_color(disp_bus & 0xffffff);
	}
    }
}
