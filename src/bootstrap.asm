start:
    ; Needs explaining. 
    mov ax, 07C0h                   ; 07C0h is the address where the bootloader has been loaded by the computer. 
    mov ds, ax                      ; ds the ds register can only be set by another register. 

    mov si, title_string            ; load the title_string address into si 
    call print_string               ; push the next instruction address to the stack and jump to print_string. 

    mov si, message_string
    call print_string

    call load_kernel_from_disk      ; Load the kernel and jump to the start of it
    jmp 0900h:0000h                 ; jump to explicit memory address <address>:<offset>

load_kernel_from_disk:
    mov ax, 0900h
    mov es, ax

    mov ah, 02h                     ; service number that reads sector from the hard drive and loads it into memory.
    mov al, 01h                     ; the number of sectors that we want to read.

    mov ch, 0h                      ; the number of the track we will like to read from.
    mov cl, 02h                     ; the number of the sector we want to read from.

    mov dh, 0h                      ; the head number
    mov dl, 80h                     ; type of disk. 0h = floppy disk, 80h = Disk #0, 81h = Disk #1

    mov bx, 0h                      ; the memory address that the content will be loaded to.
    int 13h                         ; Services related to hard disks

    jc kernel_load_error            ; when the content is loaded successfully, BIOS service 13h:02h is going to 
                                    ; set the carry flag to 0, otherwise to 1 and stores the error code to in ax.
                                    ; the jc instructions jumps when CF = 1.

    ret                             ; go back to the caller next instruction. 

kernel_load_error:
    mov si, load_error_string
    call print_string
    jmp $                           ; infinite loop

print_string:
    mov ah, 0Eh

print_char:
    lodsb
    cmp al, 0
    je print_finished

    int 10h

    jmp print_char

print_finished:
    mov al, 10d                    ; new line
    int 10h

    ; read current cursor position
    mov ah, 03h
    mov bh, 0
    int 10h

    ; move cursor to the beginning
    mov ah, 02h
    mov dl, 0
    int 10h  

    ret

; String to print
title_string      db 'The Bootloader of 539Kernel.', 0
message_string    db 'The kernel is loading...', 0
load_error_string db 'The kernel cannot be loaded', 0

; fill the remaning bytes with zeros except the last two which are needed for the BIOS magic number.
times 510-($-$$) db 0

;; write the magic number
dw 0xAA55


