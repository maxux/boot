[ORG 0]
    jmp 07C0h:start     ; BIOS bootstrap address is 07C0


init db '[+] initializing system', 0
idle db '[+] waiting for interrupt', 0

keypress db 'KeyPressed', 0
buffer db ' ', 0

keymap db '*',   0, '1', '2', '3', '4', '5', '6', '7', '8', '9',  '0', '-', '=', '*', '*'
       db 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[',  ']',  13, '*', 'a', 's'
       db 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', '\\', 'z', 'x', 'c', 'v', 'b'
       db 'n', 'm', ',', '.', '/', '*', '*', '*', ' ', '*', '*',  '*', '*', '*', '*', '*'
       db '*', '*', '*', '*', '*', '*', '*', '*', '*', '*', '*',  '*', '*', '*', '*', '*'
       db '*', '*', '*', '*', '*', '*', '*', '*', '*', '*', '*',  '*', '*', '*', '*', '*'
       db '*', '*', '*', '*', '*', '*', '*', '*', '*', '*', '*',  '*', '*', '*', '*', '*'
       db '*', '*', '*', '*', '*', '*', '*', '*', '*', '*', '*',  '*', '*', '*', '*', '*'

start:
    mov ax, cs      ; set segment register
    mov ds, ax      ; set segment register
    mov es, ax      ; set segment register


main:
    call clear      ; clear the screen
    
    mov bl, 0x0B    ; cyan
    mov si, init
    call print
    
    ; install keyboard handler
    push ds
    push 0
    pop ds
    cli
    mov [4 * 9], word __handler_keyboard   ; interrupt 9
    mov [4 * 9 + 2], cs                    ; interrupt 9
    sti
    pop ds
    
    call newline
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
;
; write a character
;
putc:
    push ax

    mov ah, 0x0E     ; write character
    int 0x10
    
    pop ax
    ret

;
; return cursor position in DH and DL
;
curpos:
    push ax
    push bx
    push cx
    
    mov ah, 0x03
    xor bx, bx
    int 0x10
    
    pop cx
    pop bx
    pop ax

;
; compute a string length, return value on CX
;
strlen:
    push ax
    push si

    xor cx, cx
    
    .check:
        lodsb
        cmp al, 0x00
        jne .next
        
        pop si
        pop ax
        ret
    
    .next:
        inc cx
        jmp .check

newline:
    pusha
    
    mov al, 0x0D
    call putc

    mov al, 0x0A
    call putc
    
    popa
    ret




__handler_keyboard:
    pusha

    in al, 60h    ; read code

    test al, 80h  ; ignore codes with high bit set
    jnz .end

    xor bx, bx
    mov bl, al
    mov al, [cs:bx + keymap] ; keymap + index
    mov [buffer], al         ; moving key into buffer
    
    ; testing key
    cmp al, 0     ; ESC key is used to reset
    je .reset

    ; print the buffer
    mov bl, 0x0F
    mov si, buffer
    call print

    .end:
        ; send EOI
        mov al, 61h
        out 20h, al
        
        popa
        iret
    
    .reset:
        db 0x0EA
        dw 0x0000 
        dw 0xFFFF








;
; hang, end of code
;
hang:
    ; display a message then hang
    mov bl, 0x08  ; green on back
    mov si, idle
    call print
    
    call newline
    
    .loop:
        hlt ; reduce cpu usage
        jmp .loop





; pads the file to make it a valid bootsector
; it must ends with 0xAA55
times 510-($-$$) db 0
dw 0x0AA55
