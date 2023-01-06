.include "salaga_io_constants.inc"

.globl slg_disp_set_pixel
.type  slg_disp_set_pixel, @function

slg_disp_set_pixel:
set_col_range:
	li t0, _SLG_DISP_MMIO_BASE_ADDR
	slli t1, a0, 14
	slli t2, a0, 4
	or t1, t1, t2
	li t2, 0x80000000
	or t1, t1, t2
	sw t1, 0(t0)
set_row_range:
	slli t1, a1, 14
	slli t2, a1, 4
	or t1, t1, t2
	li t2, 0x80000001
	or t1, t1, t2
	sw t1, 0(t0)
set_color:
	slli t1, a2, 16
	slli t2, a3, 8
	or t1, t1, t2
	or t1, t1, a4
	sw t1, 0(t0)
	ret
