#ifndef __SALAGA_IO_CONSTANTS
#define __SALAGA_IO_CONSTANTS

/*
 * SoC will treat all access to memory which
 * have the MSB bit of address set to 1
 */

// UART Base address
#define _UART_MMIO_BASE_ADDR 0xC0000000

// SALAGA Display base address
#define _SLG_DISP_MMIO_BASE_ADDR 0xA0000000

#endif
