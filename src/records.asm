; records.asm - Student record management
section .data
    max_students equ 50
    record_size equ 100
    
    ; Prompts
    prompt_id db "Enter student ID: ", 0
    prompt_name db "Enter student name: ", 0
    prompt_grade db "Enter grade for subject %d: ", 0
    success_msg db "Student added successfully!", 10, 0
    
    ; Formats
    fmt_int db "%d", 0
    fmt_str db "%s", 0
    fmt_print db "ID: %d, Name: %s", 10, 0
    
section .bss
    student_records resb max_students * record_size
    student_count resd 1
    
    ; Temp variables
    temp_id resd 1
    temp_name resb 50
    temp_grades resd 5
    
section .text
    global _add_student
    extern _printf, _scanf, _getchar, _flush_input
    
; Add student record
_add_student:
    push rbp
    mov rbp, rsp
    
    ; Get student ID
    lea rdi, [rel prompt_id]
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel temp_id]
    call _scanf
    
    call _flush_input
    
    ; Get student name
    lea rdi, [rel prompt_name]
    call _printf
    
    lea rdi, [rel fmt_str]
    lea rsi, [rel temp_name]
    call _scanf
    
    call _flush_input
    
    ; Get grades (simplified to just one grade for testing)
    lea rdi, [rel prompt_grade]
    mov rsi, 1
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel temp_grades]
    call _scanf
    
    call _flush_input
    
    ; Calculate record position
    mov eax, [rel student_count]
    mov ebx, record_size
    mul ebx
    
    ; Store ID
    mov ebx, [rel temp_id]
    mov [rel student_records + eax], ebx
    
    ; Store name (simplified, just copying the pointer for now)
    lea rbx, [rel temp_name]
    mov qword [rel student_records + eax + 4], rbx
    
    ; Store grade
    mov ebx, [rel temp_grades]
    mov [rel student_records + eax + 54], ebx
    
    ; Increment student count
    inc dword [rel student_count]
    
    ; Display success message
    lea rdi, [rel success_msg]
    call _printf
    
    ; Optionally display the added student info
    lea rdi, [rel fmt_print]
    mov esi, [rel temp_id]
    lea rdx, [rel temp_name]
    call _printf
    
    pop rbp
    ret