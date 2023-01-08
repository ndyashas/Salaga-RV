#include "salagagl.h"
#include "sim_salagagl.h"

void draw_rectangle(int x, int y, int width, int height, Color color)
{
#ifdef SALAGA_SIM
    sim_draw_rectangle(x, y, width, height, color.r, color.g, color.b);
#endif
}
