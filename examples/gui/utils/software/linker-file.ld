OUTPUT_ARCH( "riscv" )

ENTRY(_start)

MEMORY
{
	MEM (RWX) : ORIGIN = 0x00000000, LENGTH = 0x00002000 /* 8 KBytes */
}

SECTIONS
{
	.pinned_array_section  0x00000000 :
	{
		. = ALIGN(4);
		KEEP(*(.pinned_array_section));
		. = ALIGN(4);
	} > MEM

	everything 0x00000050 :
	{
		. = ALIGN(4);
		start.o (.text);
		*(.*);
		. = ALIGN(4);
	} > MEM

	PROVIDE(end = .);
	PROVIDE(stack_start = LENGTH(MEM));
}
