; dasboot.asm - (c) 2016 James S Renwick
; --------------------------------------
; Authors: James S Renwick
;
; Example first-stage bootloader for use
; on a floppy drive.
;
%define BOOT_SIZE 512
%define KERNEL_SIZE 2048
%define BREAKPOINT xchg bx, bx
; Be careful when changing these - segmentation
; can cause nasty problems
%define READ_BUFFER_BASE 0x7E00
%define READ_BUFFER_LENGTH 0x81FF

; FOR THIS SIMPLE EXAMPLE BOOTLOADER, WE REQUIRE 
; READ_BUFFER_LENGTH >= KERNEL_SIZE

[BITS 16]
[org 0x7c00]

; ---------------------------------------
; [[noreturn]] void boot_start_16()
; ---------------------------------------
[global boot_start_16]
boot_start_16:
    sti ; Make sure interrupts are enabled

    ; Set up stack (0x500-0x7C00 is free memory)
    mov ax, 0
    mov ss, ax
    mov sp, 0x7C00

    ; Enable A20 line for 1MB address access
    call enable_a20_16
    ; Get video mode info
    call get_video_mode_16
    ; Get drive info
    call get_drive_info_16
    ; Load kernel binary
    call load_kernel_16
    ; Load GDT
    call load_gdt_16
    ; Enter protected mode & jump to kernel entry point
    jmp jump_to_kernel_16


load_gdt_16:
    xor eax, eax

    ; Compute linear GDT offset
    mov ax,  ds
    shl eax, 4
    add eax, gdt_start
    mov [gdtr + 2], eax

    ; Compute GDT length
    mov eax, gdt_end
    sub eax, gdt_start
    sub eax, 1
    mov [gdtr], ax

    ; Load GDT
    lgdt [gdtr]
    ret


enable_a20_16:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret


load_kernel_16:
    pusha
    mov dl, 0h ; Select drive (0 for primary floppy)
    call get_drive_info_16

    ; Set buffer address
    mov ebx, READ_BUFFER_BASE
    shr ebx, 4
    mov es, bx
    mov ebx, READ_BUFFER_BASE
    and bx, 1111b

    ; Set start sector/cylinder/head
    mov cl, 2  ; Hard-code sector to skip boot sector (indexes start from 1)
    mov ch, 0
    mov dh, 0

    ; Set no. of sectors to read
    mov eax, KERNEL_SIZE
    shr eax, 9
    inc ax

    call read_drive_16

    popa
    ret


get_drive_info_16:
    xor ecx, ecx
    ; Request drive info
    mov [drive_info.drive], dl
    mov ah, 8h
    int 13h

    ; Decode max cylinder no.
    mov al, ch
    mov ah, cl
    shr ah, 6
    mov [drive_info.max_cylinder], ax

    ; Get max sector & head no.
    and cl, 00111111b
    mov [drive_info.max_sector], cl
    mov [drive_info.max_head], dh
    mov [drive_info.drive_count], dl

    ret


reset_drive_16:
    mov dl, [drive_info.drive]
    mov ah, 0h
    int 13h
    ret


read_drive_16:
    mov si, 3 ; Retry counter
.retry:
    call reset_drive_16
    mov ah, 2h
    int 13h

    test ah, 0
    jz .end
    dec si
    jnz .retry

    ; Failed too many times, print error & halt
    push word [SZ_ERROR_CANNOT_READ]
    push ERROR_CANNOT_READ
    call print_error_16
    cli
    hlt
.end:
    ret


get_video_mode_16:
    mov ah, 0Fh
    int 10h

    mov [video_mode.mode], al
    mov [video_mode.columns], ah
    mov [video_mode.page], bh

    ret 


print_error_16:
    push bp
    mov bp, word [esp+4]
    mov cx, word [esp+6]

    mov ax, ds
    mov es, ax

    mov ax, 1300h
    mov bx, 0x0C

    int 10h
    pop bp
    ret


jump_to_kernel_16:
    cli ; Disable interrupts

    ; Set PE bit in CR0
    mov eax, cr0  
    or  eax, 1
    mov cr0, eax

    ; Set segment selectors and long-jump to 32-bit code
    mov ax, 10h
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 8h:bootstrap


; -----------------------------------------------------------
[BITS 32]

; Launch C entry point
bootstrap:
    ; Set up stack (0x500-0x7C00 is free memory)
    mov esp, 0x7C00

    push video_mode  ; Pointer to video mode info
    push drive_info  ; Pointer to drive info
    push 0xDA5B007   ; Magic for sanity check

    ; Use return to call kernel entry
    push .end

    BREAKPOINT
    push dword [READ_BUFFER_BASE]
    ret

.end:
    cli
    hlt 


; ===========================================================


ERROR_CANNOT_READ:
    db 'ERROR READING KERNEL. ABORTING.'
SZ_ERROR_CANNOT_READ:
    dw $-ERROR_CANNOT_READ

gdtr:
    dw 0
    dd 0

align 4
gdt_start:
.0: ; Null descriptor
    dw 0x0000
    dw 0x0000
    db 0x00
    db 10010000b
    dw 0
.1: ; Code descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 1100_1111b
    db 0
.2: ; Data descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 1100_1111b
    db 0
gdt_end:


align 4
drive_info:
    .drive:        db 0 ; Drive no.
    .max_cylinder: dw 0 ; Max cylinder no.
    .max_head:     db 0 ; Max head no.
    .max_sector:   db 0 ; Max sector no.
    .drive_count:  db 0 ; Drive count
                   dw 0 ; -padding-

align 4
video_mode:
    .mode:    db 0 ; Video Mode
    .columns: db 0 ; Number of columns
    .page:    db 0 ; Current active page
              db 0 ; -padding-


; Insert two-byte boot signature
asm_end:
    times BOOT_SIZE-2-($-$$) db 0
dw 0xAA55
