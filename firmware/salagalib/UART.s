.include "salaga_io_constants.inc"

.globl UART_putchar
.type  UART_putchar, @function

UART_putchar:
	li t0, _UART_MMIO_BASE_ADDR
	sw a0, 0(t0)
wait_to_send:
	lw t1, 0(t0)
	andi t1, t1, 256 # 9th bit is the busy bit.
	bne t1, x0, wait_to_send
	ret
