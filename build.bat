@echo off
nasm dasboot.asm -o dasboot.bin
bash -c "dd if=/dev/zero of=floppy.img bs=1024 count=1440"
bash -c "dd if=dasboot.bin of=floppy.img bs=1 count=512 conv=notrunc"
