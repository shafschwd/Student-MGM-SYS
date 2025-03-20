; search.asm - Student search functionality
section .data
    ; Messages
    search_header db "===== Student Search =====", 10, 0
    search_prompt db "Enter student ID to search: ", 0
    student_found_fmt db "Student found!", 10, "ID: %d, Name: %s, Grade: %d", 10, 0
    student_not_found db "Student with ID %d not found.", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    fmt_int db "%d", 0
    
section .bss
    search_id resd 1       ; Buffer for search ID
    
section .text
    global _search_student
    extern _printf, _scanf, _flush_input
    extern _get_student_count, _get_student_id, _get_student_name, _get_student_grade
    
; Search for a student by ID
_search_student:
    push rbp
    mov rbp, rsp
    push rbx                    ; Save non-volatile registers
    push r12
    push r13
    push r14
    push r15
    
    ; Display header
    lea rdi, [rel search_header]
    xor eax, eax
    call _printf
    
    ; Check if there are any students
    call _get_student_count
    test eax, eax
    jz .no_students
    
    ; Save student count
    mov ebx, eax
    
    ; Prompt for ID to search
    lea rdi, [rel search_prompt]
    xor eax, eax
    call _printf
    
    ; Read ID
    lea rdi, [rel fmt_int]
    lea rsi, [rel search_id]
    xor eax, eax
    call _scanf
    
    call _flush_input
    
    ; Search through all students
    xor r12d, r12d               ; Initialize counter
.search_loop:
    cmp r12d, ebx                ; Check if we've searched all students
    jge .not_found
    
    ; Get current student ID
    mov edi, r12d
    call _get_student_id
    
    ; Compare with search ID
    cmp eax, [rel search_id]
    je .found
    
    inc r12d                     ; Increment counter
    jmp .search_loop
    
.found:
    ; Get student name and grade
    mov edi, r12d
    call _get_student_name
    mov r14, rax                ; r14 = pointer to student name
    
    mov edi, r12d
    call _get_student_grade
    mov r15d, eax               ; r15d = student grade
    
    ; Display student info
    lea rdi, [rel student_found_fmt]
    mov esi, [rel search_id]    ; ID
    mov rdx, r14                ; Name pointer
    mov ecx, r15d               ; Grade
    xor eax, eax
    call _printf
    jmp .done
    
.not_found:
    ; Not found
    lea rdi, [rel student_not_found]
    mov esi, [rel search_id]
    xor eax, eax
    call _printf
    jmp .done
    
.no_students:
    lea rdi, [rel no_students_msg]
    xor eax, eax
    call _printf
    
.done:
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    
    pop rbp
    ret