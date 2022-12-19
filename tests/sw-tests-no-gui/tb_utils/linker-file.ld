OUTPUT_ARCH( "riscv" )

ENTRY(main)

MEMORY
{
	MEM (RWX) : ORIGIN = 0x00000000, LENGTH = 0x00004000 /* 16 KBytes */
}

SECTIONS
{
	.pinned_array_section  0x00000000 :
	{
		. = ALIGN(4);
		KEEP(*(.pinned_array_section));
	} > MEM

	everything 0x00000050 :
	{
		. = ALIGN(4);
		program.o (.text);
		*(.*);
	} > MEM
}
