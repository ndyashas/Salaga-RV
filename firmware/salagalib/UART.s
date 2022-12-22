.include "salaga_io_constants.inc"

.globl UART_putchar
.type  UART_putchar, @function

UART_putchar:
	sw a0, _UART_MMIO_ADDR(x0)
wait_to_send:
	lw t0, _UART_MMIO_ADDR(x0)
	andi t0, t0, 1
	beq t0, x0, wait_to_send
	ret
	
