
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
    
    mov dl, 1
    mov dh, 1
    call _move
    
    mov bl, 09h     ; yellow on back
    mov si, hello
    call print
    
    ; jmp _main_print
    jmp hang

;
; print a string (in teletype mode)
; string must be given by SI
;
puts:
    lodsb           ; load next character into AL

    cmp al, 0       ; end of the string
    je _puts_end

    call _printy
    
    jmp puts
    
    _puts_end:
        ret

;
; print a string with attributes (via BL)
; string must be given by SI
;
print:    
    mov ah, 13h
    mov al, 01h
    mov bh, 0
    
    call _strlen
    call _curpos

    mov bp, si
    int 10h

    ret

;
; functions
;

;
; clear the screen (reset video mode)
;
clear:
    push ax
    
    mov ah, 0h
    mov al, 3h
    int 10h
    
    pop ax
    ret

;
; use DH (row) and DL (cols) as paremeters
;
_move:
    push ax
    push bx
    
    mov ah, 02h     ; move cursor
    mov bh, 0       ; page 0
    int 10h
    
    pop bx
    pop ax
    ret

; write a character
_putc:
    push ax
    push cx

    mov ah, 09h     ; write character
    mov cx, 1
    int 10h
    
    pop cx
    pop ax
    ret

; print in teletype mode
_printy:
    push ax
    push bx
    
    mov ah, 0Eh     ; teletype output
    mov bx, 0
    int 10h
    
    pop bx
    pop ax
    ret

_curpos:
    push ax
    push bx
    push cx
    
    mov ah, 03h
    mov bh, 0
    int 10h
    
    pop cx
    pop bx
    pop ax
    
_strlen:
    push ax
    push si
    mov cx, 0
    
    _strlen_check:
        lodsb
        cmp al, 0
        jne _strlen_next
        
        pop si
        pop ax
        ret
    
    _strlen_next:
        inc cx
        jmp _strlen_check

;
; hang, end of code
;
hang:
    mov bx, 0
    mov dh, 24
    mov dl, 50
    call _move
    
    mov si, success
    call puts
    
    _hang:
        hlt ; reduce cpu usage
        jmp _hang



; pads the file to make it a valid bootsector
; it must ends with 0xAA55

times 510-($-$$) db 0
dw 0AA55h
