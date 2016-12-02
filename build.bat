@echo off
nasm dasboot.asm -o bin/dasboot.bin
bash -c "dd if=/dev/zero of=bin/floppy.img bs=1024 count=1440"
bash -c "dd if=bin/dasboot.bin of=bin/floppy.img bs=1 count=512 conv=notrunc"

gcc -c -Os -m32 -march=i686 -ffreestanding -Wall -Wextra -I. -o bin/stage2.o stage2.c
ld -m i386pe -static -Tlink.ld -nostdlib --nmagic -Map bin/stage2-map.txt -o bin/stage2.exe bin/stage2.o
objcopy -O binary bin/stage2.exe bin/stage2.bin
objdump -d bin/stage2.exe > bin/disasm.txt

bash -c "dd if=bin/stage2.bin of=bin/floppy.img bs=1 seek=512 count=8228 conv=notrunc"
