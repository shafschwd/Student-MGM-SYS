; records.asm - Simplified student record management
section .data
    ; Prompts
    prompt_id db "Enter student ID: ", 0
    prompt_name db "Enter student name: ", 0
    prompt_grade db "Enter grade for subject %d: ", 0
    success_msg db "Student added successfully!", 10, 0
    
    ; Formats
    fmt_int db "%d", 0
    fmt_str db "%s", 0
    fmt_print db "Added student - ID: %d, Name: %s, Grade: %d", 10, 0
    
    ; Counter
    student_count dd 0
    
section .bss
    ; We'll use individual variables for now instead of an array
    student_id resd 1
    student_name resb 50
    student_grade resd 1
    
section .text
    global _add_student
    extern _printf, _scanf, _flush_input
    
; Add student record - simplified version
_add_student:
    push rbp
    mov rbp, rsp
    
    ; Get student ID
    lea rdi, [rel prompt_id]
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel student_id]
    call _scanf
    
    call _flush_input
    
    ; Get student name
    lea rdi, [rel prompt_name]
    call _printf
    
    lea rdi, [rel fmt_str]
    lea rsi, [rel student_name]
    call _scanf
    
    call _flush_input
    
    ; Get grade (simplified to just one grade)
    lea rdi, [rel prompt_grade]
    mov rsi, 1
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel student_grade]
    call _scanf
    
    call _flush_input
    
    ; Increment student count
    inc dword [rel student_count]
    
    ; Display success message and student info
    lea rdi, [rel success_msg]
    call _printf
    
    lea rdi, [rel fmt_print]
    mov esi, [rel student_id]
    lea rdx, [rel student_name]
    mov ecx, [rel student_grade]
    call _printf
    
    pop rbp
    ret