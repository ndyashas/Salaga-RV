OUTPUT_ARCH( "riscv" )

ENTRY(reset_handler)

/*
 * +-----------+  0x00000000
 * |           |      |
 * |           |      8Kbytes     .text section
 * |           |      |
 * |           |      |
 * +-----------+  0x00010000
 * |           |      |
 * |           |      4Kbytes     .salaga_mm_region
 * |           |      |
 * +-----------+  0x00018000
 * |           |      |
 * |           |      4Kbytes     .data
 * |           |      |
 * +-----------+  0x00020000
 */

MEMORY
{
	I_MEM : ORIGIN = 0x00000000, LENGTH = 0x00010000 /* 8 KBytes */
	D_MEM : ORIGIN = 0x00010000, LENGTH = 0x00010000 /* 8 KBytes */
}

SECTIONS
{
	.text :
	{
		. = ALIGN(4);
		../common/startup-script.o(.text)
		*(.text)
		. = ALIGN(4);
	} > I_MEM

	.data :
	{
		. = ALIGN(4);
		_start_of_data = .;
		KEEP(*(.salaga_mm_region)) /* This is ~4Kbytes */
		. = _start_of_data + 4*1024;
		*(.data)
		. = ALIGN(4);
	} > D_MEM
}
