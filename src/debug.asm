; debug.asm - Debug utilities
bits 64

section .data
    debug_msg db "DEBUG: %s", 10, 0
    debug_int db "DEBUG INT: %d", 10, 0

section .text
    global print_debug, print_debug_int
    extern printf

; Print a debug message
; Parameters:
;   rdi = string to print
print_debug:
    push rbp
    mov rbp, rsp
    
    ; Save original string pointer
    mov rdx, rdi
    
    ; Load format
    lea rdi, [rel debug_msg]
    mov rsi, rdx
    
    ; Call printf
    xor eax, eax
    call printf
    
    pop rbp
    ret

; Print a debug integer
; Parameters:
;   rdi = integer to print
print_debug_int:
    push rbp
    mov rbp, rsp
    
    ; Save integer value
    mov rsi, rdi
    
    ; Load format
    lea rdi, [rel debug_int]
    
    ; Call printf
    xor eax, eax
    call printf
    
    pop rbp
    ret
