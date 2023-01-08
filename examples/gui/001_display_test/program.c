#include <stdlib.h>
#include <string.h>
#include <salagalib.h>
#include <salagagl.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    int i, row, col;
    Color color_i;

    Color red = {255, 0, 0};
    Color green = {0, 255, 0};
    Color blue = {0, 0, 255};

    Color color_array[3] = {red, green, blue};

    ///--------------------- Full screen color - set_pixel -----------------------
    for (i = 0; i < 3; ++i) {
	color_i = color_array[i];
	for (row = 0; row < SALAGA_DISPLAY_HEIGHT; ++row) {
	    for (col = 0; col < SALAGA_DISPLAY_WIDTH; ++col) {
		set_pixel(col, row, color_i);
	    }
	}
	sleep(50);
    }

    ///--------------------- Full screen color - draw_line ---- ------------------
    for (i = 0; i < 3; ++i) {
	color_i = color_array[i];
	for (row = 0; row < SALAGA_DISPLAY_HEIGHT; ++row) {
	    draw_line(0, row, SALAGA_DISPLAY_WIDTH-1, row, color_i);
	}
	sleep(75);
    }

    ///--------------------- Full screen color - draw_rectangle ------------------
    for (i = 0; i < 3; ++i) {
	color_i = color_array[i];
	draw_rectangle(0, 0, SALAGA_DISPLAY_WIDTH, SALAGA_DISPLAY_HEIGHT, color_i);
	sleep(100);
    }

    return 0;
}
