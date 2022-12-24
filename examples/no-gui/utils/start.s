.global _start

_start:
	la sp, stack_start
	call main
	nop
	nop
	nop
	nop
	nop
	nop
	ebreak
