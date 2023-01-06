#include <stdlib.h>
#include <string.h>
#include <salagagl.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

int main()
{
    Color color;
    
    slg_draw_line(0, 0, 0, 0, color);

    return 0;
}
