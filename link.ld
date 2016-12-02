ENTRY(_boot_main);
SECTIONS
{
    . = 0x7E00;
    .entryAddr : AT(0x7E00)
    {
        *(.entryAddr);
    }
    .text : AT(0x7E04)
    {
        _text = .;
        *(.text);
        _text_end = .;
    }
    .data :
    {
        _data = .;
        *(.bss);
        *(.bss*);
        *(.data);
        *(.rodata*);
        *(COMMON)
        _data_end = .;
    }
    /DISCARD/ :
    {
        *(.note*);
        *(.iplt*);
        *(.igot*);
        *(.rel*);
        *(.comment);
    }
}
