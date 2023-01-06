#ifndef __SALAGA_SIMULATION_DISPLAY
#define __SALAGA_SIMULATION_DISPLAY

#include <stdio.h>
#include <SDL.h>

#define SIM_DISPLAY_WIDTH  240
#define SIM_DISPLAY_HEIGHT 180

typedef struct Pixel {
    uint8_t a;
    uint8_t b;
    uint8_t g;
    uint8_t r;
} Pixel ;

class Salaga_Sim_Display {
    Pixel *display_buffer_;

    int curr_col_start_;
    int curr_col_end_;
    int curr_col_ptr_;
    
    int curr_row_start_;
    int curr_row_end_;
    int curr_row_ptr_;

    SDL_Window *sdl_window_ = NULL;
    SDL_Renderer *sdl_renderer_ = NULL;
    SDL_Texture *sdl_texture_ = NULL;

    SDL_Event e_;
  public:

    Salaga_Sim_Display();
    ~Salaga_Sim_Display();

    void draw();
    void debug();

    bool got_quit();
    
    void set_col_ptr(int col_ptr_start, int col_ptr_end);
    void set_row_ptr(int row_ptr_start, int row_ptr_end);
    void put_color(unsigned int color_24bit_rgb);

    void process_input(int disp_en, int disp_DC, int disp_bus);
};

#endif
