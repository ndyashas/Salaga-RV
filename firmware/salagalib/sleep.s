.globl sleep
.type  sleep, @function

sleep:
	mv t1, a0
wait_loop:
	li t2, 1000
	addi t1, t1, -1
ms_loop:
	addi t2, t2, -1
	blt x0, t2, ms_loop	
	blt x0, t1, wait_loop
	ret
