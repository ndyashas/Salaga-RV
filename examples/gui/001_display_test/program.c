#include <stdlib.h>
#include <string.h>
#include <salagaio.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    int i, j;

    // Fill red by setting each pixel
    for (i = 0; i < SALAGA_DISPLAY_HEIGHT; ++i) {
	for (j = 0; j < SALAGA_DISPLAY_WIDTH; ++j) {
	    slg_disp_set_pixel(j, i, 255, 0, 0);
	}
    }

    // Fill green by using a rectangle
    slg_disp_draw_rectangle(0, 0, SALAGA_DISPLAY_WIDTH, SALAGA_DISPLAY_HEIGHT, 0, 255, 0);

    // Blue - half pixels, hald rectangle
    for (i = 0; i < SALAGA_DISPLAY_HEIGHT / 2; ++i) {
	for (j = 0; j < SALAGA_DISPLAY_WIDTH; ++j) {
	    slg_disp_set_pixel(j, i, 0, 0, 255);
	}
    }
    slg_disp_draw_rectangle(SALAGA_DISPLAY_HEIGHT / 2, 0, SALAGA_DISPLAY_WIDTH, SALAGA_DISPLAY_HEIGHT, 0, 0, 255);

    // White from bottom to top - pixels
    for (i = SALAGA_DISPLAY_HEIGHT - 1; i > 0; --i) {
	for (j = SALAGA_DISPLAY_WIDTH - 1; j > 0; --j) {
	    slg_disp_set_pixel(j, i, 255, 255, 255);
	}
    }

    return 0;
}
