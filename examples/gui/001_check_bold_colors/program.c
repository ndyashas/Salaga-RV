#include <stdlib.h>
#include <string.h>
#include <salagaio.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    int i, j;

    // Red
    for (i = 0; i < SALAGA_DISPLAY_HEIGHT; ++i) {
	for (j = 0; j < SALAGA_DISPLAY_WIDTH; ++j) {
	    slg_disp_set_pixel(j, i, 255, 0, 0);
	}
    }

    // Green
    for (i = 0; i < SALAGA_DISPLAY_HEIGHT; ++i) {
	for (j = 0; j < SALAGA_DISPLAY_WIDTH; ++j) {
	    slg_disp_set_pixel(j, i, 0, 255, 0);
	}
    }

    // Blue
    for (i = 0; i < SALAGA_DISPLAY_HEIGHT; ++i) {
	for (j = 0; j < SALAGA_DISPLAY_WIDTH; ++j) {
	    slg_disp_set_pixel(j, i, 0, 0, 255);
	}
    }

    // White
    for (i = 0; i < SALAGA_DISPLAY_HEIGHT; ++i) {
	for (j = 0; j < SALAGA_DISPLAY_WIDTH; ++j) {
	    slg_disp_set_pixel(j, i, 255, 255, 255);
	}
    }

    return 0;
}
