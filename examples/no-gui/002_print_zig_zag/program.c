#include <stdlib.h>
#include <string.h>
#include <salagaio.h>

#define PINNED_ARRAY_SIZE 20
unsigned int pinned_array[PINNED_ARRAY_SIZE] __attribute__((section(".pinned_array_section")));

#define WIDTH 10

void print_negative_slope()
{
    int x;
    int y;

    // Slope is -0.5
    int x_incr = 1;
    int y_incr = 2;

    int _HEIGHT = WIDTH;

    for (y = 0; y < _HEIGHT; y += y_incr) {
	for (x = 0; x < WIDTH; x += x_incr) {
	    if (x == y) {
		putchar('*');
	    } else {
		putchar(' ');
	    }
	}
	putchar('\n');
    }
}

void print_positive_slope()
{
    int x;
    int y;

    // Slope is 0.5
    int x_incr = 1;
    int y_incr = 2;

    int _HEIGHT = WIDTH;

    for (y = 0; y < _HEIGHT; y += y_incr) {
	for (x = WIDTH; x > 0; x -= x_incr) {
	    if (x == y) {
		putchar('*');
	    } else {
		putchar(' ');
	    }
	}
	putchar('\n');
    }
}

int main()
{
    print_negative_slope();
    print_positive_slope();
    print_negative_slope();

    return 0;
}
