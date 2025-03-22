; input.asm - Input handling routines for Linux
bits 64

section .data
    scan_int_fmt db "%d", 0
    scan_str_fmt db "%s", 0
    input_buffer_msg db "Input buffer cleared.", 10, 0
    
section .text
    global read_int, read_string, clear_input_buffer, flush_input
    extern scanf, printf, getchar
    
; Function to read an integer
; Parameters: none
; Returns: eax = integer read
read_int:
    push rbp
    mov rbp, rsp
    sub rsp, 16         ; Allocate space for local variable
    
    mov rdi, scan_int_fmt
    lea rsi, [rsp]      ; Store result on stack
    xor eax, eax
    call scanf
    
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
    
    mov rdi, scan_str_fmt
    mov rsi, [rbp-8]    ; Get buffer address
    xor eax, eax
    call scanf
    
    call flush_input
    
    pop rsi
    pop rdi
    pop rbp
    ret
    
; Function to clear input buffer
clear_input_buffer:
    push rbp
    mov rbp, rsp
    
.loop:
    call getchar
    cmp eax, 10         ; Check for newline
    je .done
    cmp eax, -1         ; Check for EOF
    je .done
    jmp .loop
    
.done:
    pop rbp
    ret
    
; Clear the input buffer (especially after scanf)
flush_input:
    push rbp
    mov rbp, rsp
    sub rsp, 8       ; Align stack
    
.read_loop:
    ; Call getchar() to read a character
    call getchar
    
    ; Check if EOF or newline
    cmp eax, -1      ; EOF
    je .done
    cmp eax, 10      ; Newline
    je .done
    
    ; Keep reading
    jmp .read_loop
    
.done:
    add rsp, 8
    pop rbp
    ret