#include "salagagl.h"
#include "sim_salagagl.h"

void set_pixel(int x, int y, Color color)
{
#ifdef SALAGA_SIM
    sim_set_pixel(x, y, color.r, color.g, color.b);
#endif
}
