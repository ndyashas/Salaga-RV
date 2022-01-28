OUTPUT_ARCH( "riscv" )

ENTRY(reset_handler)

MEMORY
{
	I_MEM : ORIGIN = 0x00000000, LENGTH = 0x00000400 /* 1 KBytes */
	D_MEM : ORIGIN = 0x00000400, LENGTH = 0x00000400 /* 1 KBytes */
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
		KEEP(*(.salaga_mm_region)) /* This is ~512 bytes */
		. = . + 512;
		*(.data)
		. = ALIGN(4);
	} > D_MEM
}
