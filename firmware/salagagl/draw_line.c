#include "salagagl.h"
#include "sim_salagagl.h"

void draw_line(int x1, int y1, int x2, int y2, Color color)
{
#ifdef SALAGA_SIM
    sim_draw_line(x1, y1, x2, y2, color);
#endif
}
