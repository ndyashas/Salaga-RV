OUTPUT_ARCH( "riscv" )

ENTRY(reset_handler)

/*
 * +-----------+  0x00000000
 * |           |      |
 * |           |      8Kbytes     .text section
 * |           |      |
 * |           |      |
 * +-----------+  0x00002000
 * |           |      |
 * |           |      2Kbytes     .salaga_mm_region
 * |           |      |
 * +-----------+  0x00002800
 * |           |      |
 * |           |      6Kbytes     .data
 * |           |      |
 * +-----------+  0x00003fff
 */

MEMORY
{
	MEM : ORIGIN = 0x00000000, LENGTH = 0x00004000 /* 16 KBytes */
}

SECTIONS
{
	.text :
	{
		. = ALIGN(4);
		../common/startup-script.o(.text)
		*(.text)
		. = ALIGN(4);
	} > MEM

	.salaga_mm_region 0x00002000:
	{
		. = ALIGN(4);
		_start_of_salaga_mm_region = .;
		KEEP(*(.salaga_mm_region)) /* This is ~2Kbytes */
		. = ALIGN(4);
	} > MEM

	.data 0x00002800:
	{
		. = ALIGN(4);
		*(.data)
		. = ALIGN(4);
	} > MEM
}
