// Aggregate all salagagl functions into one place

#ifndef __SALAGA_GL
#define __SALAGA_GL

#define SALAGA_DISPLAY_WIDTH  240
#define SALAGA_DISPLAY_HEIGHT 180

typedef struct Color {
    int r;
    int g;
    int b;
} Color;

void set_pixel(int x, int y, Color color);
void draw_rectangle(int x, int y, int width, int height, Color color);

#endif
