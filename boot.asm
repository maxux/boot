
[ORG 0]
    jmp 07C0h:start     ; BIOS bootstrap address is 07C0


hello db 'Hello world !', 0
success db '[code ended successful, hang]', 0

start:
    mov ax, cs      ; set segment register
    mov ds, ax      ; set segment register
    mov es, ax      ; set segment register


main:
    call clear      ; clear the screen
    
    mov bl, 0x09    ; yellow on back
    mov si, hello
    call print
    
    jmp hang

;
; print a string with attributes (via BL)
; string must be given by SI
;
print:
    pusha

    mov ah, 0x13
    mov al, 0x01
    mov bh, 0x00
    
    call strlen
    call curpos

    mov bp, si
    int 0x10

    popa
    ret

;
; functions
;

;
; clear the screen (reset video mode)
;
clear:
    push ax
    
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    pop ax
    ret

;
; use DH (row) and DL (cols) as paremeters
;
curmove:
    pusha
    
    mov ah, 0x02     ; move cursor
    mov bh, 0x00     ; page 0
    int 0x10
    
    popa
    ret

; write a character
putc:
    push ax

    mov ah, 0x0E     ; write character
    int 0x10
    
    pop ax
    ret

curpos:
    push ax
    push bx
    push cx
    
    mov ah, 0x03
    mov bh, 0x00
    mov bl, 0x00
    int 0x10
    
    pop cx
    pop bx
    pop ax
    
strlen:
    pusha
    mov cx, 0x00
    
    .check:
        lodsb
        cmp al, 0x00
        jne .next
        
        popa
        ret
    
    .next:
        inc cx
        jmp .check

;
; hang, end of code
;
hang:
    ; display a message then hang
    mov al, 0x0D
    call putc

    mov al, 0x0A
    call putc

    mov bl, 0x02  ; green on back
    mov si, success
    call print
    
    .loop:
        hlt ; reduce cpu usage
        jmp .loop



; pads the file to make it a valid bootsector
; it must ends with 0xAA55

times 510-($-$$) db 0
dw 0x0AA55
