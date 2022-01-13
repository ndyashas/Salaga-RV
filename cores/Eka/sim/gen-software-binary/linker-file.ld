OUTPUT_ARCH( "riscv" )

ENTRY(reset_handler)

MEMORY
{
	MEM : ORIGIN = 0x00000000, LENGTH = 0x00000100
}

SECTIONS
{
	.text :
	{
		. = ALIGN(4);
		startup-script.o(.text)
		*(.text)
		. = ALIGN(4);
	} > MEM
	.data :
	{
		. = ALIGN(4);
		*(.data)
		. = ALIGN(4);
	} > MEM
}
