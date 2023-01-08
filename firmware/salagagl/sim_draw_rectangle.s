.include "salaga_gl_constants.inc"

.globl sim_draw_rectangle
.type  sim_draw_rectangle, @function

sim_draw_rectangle:
# set_col_range:
	li t0, _SLG_DISP_MMIO_BASE_ADDR
	slli t1, a0, 14
	add t2, a0, a2
	slli t2, t2, 4
	or t1, t1, t2
	li t2, 0x80000000
	or t1, t1, t2
	sw t1, 0(t0)
# set_row_range
	slli t1, a1, 14
	add t2, a1, a3
	slli t2, t2, 4
	or t1, t1, t2
	li t2, 0x80000001
	or t1, t1, t2
	sw t1, 0(t0)
# To set color
	slli t1, a4, 16
	slli t2, a5, 8
	or t1, t1, t2
	or t1, t1, a6
	li t4, 1
	mv t5, a2
outer_loop_0:
	sub t5, t5, t4
	mv t6, a3
inner_loop_0:
	sub t6, t6, t4
	sw t1, 0(t0)
	bge t6, x0, inner_loop_0
	bge t5, x0, outer_loop_0
	ret
