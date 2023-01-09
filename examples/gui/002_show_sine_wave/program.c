#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <salagalib.h>
#include <salagagl.h>
#include <salagaio.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    int x, y, prev_x, prev_y;

    Color red   = {255, 0, 0};
    Color blue  = {0, 0, 255};
    Color white = {255, 255, 255};
    Color black = {0, 0, 0};
    
    draw_rectangle(0, 0, SALAGA_DISPLAY_WIDTH, SALAGA_DISPLAY_HEIGHT, white);

    float resolution = 0.04;
    float width = 1;
    
    print_str("Sine wave!\0");
    prev_x = 0;
    prev_y = SALAGA_DISPLAY_HEIGHT/2;
    for (x = 0; x < SALAGA_DISPLAY_WIDTH - 1; x += width) {
	y = (int)((SALAGA_DISPLAY_HEIGHT/2) - ((SALAGA_DISPLAY_HEIGHT/4) * sin(x*resolution)));
	draw_line(prev_x, prev_y, x, y, black);
	prev_x = x;
	prev_y = y;
    }

    print_str("Cosine wave!\0");
    prev_x = 0;
    prev_y = SALAGA_DISPLAY_HEIGHT/4;
    for (x = 0; x < SALAGA_DISPLAY_WIDTH - 1; x += width) {
	y = (int)((SALAGA_DISPLAY_HEIGHT/2) - ((SALAGA_DISPLAY_HEIGHT/4) * cos(x*resolution)));
	draw_line(prev_x, prev_y, x, y, red);
	prev_x = x;
	prev_y = y;
    }

    print_str("Sine + Cosine wave!\0");
    prev_x = 0;
    prev_y = SALAGA_DISPLAY_HEIGHT/4;
    for (x = 0; x < SALAGA_DISPLAY_WIDTH - 1; x += width) {
	y = (int)((SALAGA_DISPLAY_HEIGHT/2) - ((SALAGA_DISPLAY_HEIGHT/4) * (sin(x*resolution) + cos(x*resolution))));
	draw_line(prev_x, prev_y, x, y, blue);
	prev_x = x;
	prev_y = y;
    }
    
    return 0;
}
