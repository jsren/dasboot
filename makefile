# makefile - (c) 2016 James S Renwick

LD   := ld
GCC  := gcc
NASM := nasm

CFLAGS  := -std=c11 -Os -m32 -march=i686 -ffreestanding -Wall -Wextra -I.
LDFLAGS := -m i386pe -static -Tlink.ld -nostdlib -n --section-alignment 4 --warn-section-align -Map bin/stage2-map.txt

SOURCE_FILES = $(wildcard *.c)
OBJECT_FILES = $(SOURCE_FILES:%.c=bin/%.o)

all: clean-some bin/floppy.img

bin/%.o : %.c
	$(GCC) -c $(CFLAGS) -o $@ $<

bin/stage2.bin : $(OBJECT_FILES)
	$(LD) $(LDFLAGS) -o bin/stage2.exe $(OBJECT_FILES)
	objdump -d bin/stage2.exe > bin/stage2-disasm.txt
	objcopy -O binary bin/stage2.exe bin/stage2.bin

bin/dasboot.bin: dasboot.asm
	$(NASM) $(ASMFLAGS) -o $@ $<

bin/floppy.img : bin/dasboot.bin bin/stage2.bin
	dd if=/dev/zero of=bin/floppy.img bs=1024 count=1440
	dd if=bin/dasboot.bin of=bin/floppy.img bs=1 count=512 conv=notrunc
	dd if=bin/stage2.bin of=bin/floppy.img bs=1 seek=512 count=8228 conv=notrunc

clean:
	rm -rf bin/*

clean-some:
	rm -rf bin/*.img
	rm -rf bin/*.bin

