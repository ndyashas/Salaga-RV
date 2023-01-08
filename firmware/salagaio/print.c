#include "UART.h"

int putchar(int c)
{
    return UART_putchar(c);
}

void print_str(const char *string)
{
    while (*string != 0) {
	putchar(*(string++));
    }
    putchar('\n');
}
