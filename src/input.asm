; input.asm - Input handling routines

section .data
    scan_int_fmt db "%d", 0
    scan_str_fmt db "%s", 0
    input_buffer_msg db "Input buffer cleared.", 10, 0
    
section .text
    global read_int, read_string, clear_input_buffer
    extern _scanf, _printf, _getchar
    
; Function to read an integer
; Parameters: none
; Returns: eax = integer read
read_int:
    push rbp
    mov rbp, rsp
    sub rsp, 16         ; Allocate space for local variable
    
    lea rdi, [rel scan_int_fmt]
    lea rsi, [rsp]      ; Store result on stack
    xor eax, eax
    call _scanf
    
    mov eax, [rsp]      ; Move result to eax
    
    add rsp, 16
    pop rbp
    ret
    
; Function to read a string
; Parameters:
;   rdi = buffer address
;   rsi = buffer size
read_string:
    push rbp
    mov rbp, rsp
    push rdi            ; Save buffer address
    push rsi            ; Save buffer size
    
    lea rdi, [rel scan_str_fmt]
    mov rsi, [rbp-8]    ; Get buffer address
    xor eax, eax
    call _scanf
    
    call clear_input_buffer
    
    pop rsi
    pop rdi
    pop rbp
    ret
    
; Function to clear input buffer
clear_input_buffer:
    push rbp
    mov rbp, rsp
    
.loop:
    call _getchar
    cmp eax, 10         ; Check for newline
    je .done
    cmp eax, -1         ; Check for EOF
    je .done
    jmp .loop
    
.done:
    pop rbp
    ret