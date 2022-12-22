#include "UART.h"

int putchar(int c)
{
    return UART_putchar(c);
}
