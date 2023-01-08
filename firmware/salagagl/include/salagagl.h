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
void draw_line(int x1, int y1, int x2, int y2, Color color);

#endif
