#include "UART.h"
#include "salaga_io_constants.h"

int UART_putchar(int c)
{
    //TODO
    volatile unsigned char *uart_mmio_addr = (unsigned char*)_UART_MMIO_ADDR;

    *uart_mmio_addr = c;

    // Busy wait if UART not free
    while (*uart_mmio_addr != 1);

    return c;
}
