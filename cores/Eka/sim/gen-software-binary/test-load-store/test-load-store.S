.section .text
.globl main
	
main:
	li t0, 0x1234f6f8
	la t1, _data
	sw t0, 0(t1)
	sh t0, 4(t1)
	sb t0, 8(t1)

// t1 has _data address
	lw t2, 0(t1)
	lhu t3, 0(t1)
	lbu t4, 0(t1)
	lh t5, 0(t1)
	lb t6, 0(t1)
	ret

.section .data
_data:
