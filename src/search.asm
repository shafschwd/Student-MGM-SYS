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
    extern student_count, student_id, student_name, student_grade
    
; Search for a student by ID
_search_student:
    push rbp
    mov rbp, rsp
    
    ; Display header
    lea rdi, [rel search_header]
    call _printf
    
    ; Check if there are any students
    mov eax, [rel student_count]
    cmp eax, 0
    je .no_students
    
    ; Prompt for ID to search
    lea rdi, [rel search_prompt]
    call _printf
    
    ; Read ID
    lea rdi, [rel fmt_int]
    lea rsi, [rel search_id]
    call _scanf
    
    call _flush_input
    
    ; Compare with stored ID
    mov eax, [rel search_id]
    cmp eax, [rel student_id]
    je .found
    
    ; Not found
    lea rdi, [rel student_not_found]
    mov esi, [rel search_id]
    call _printf
    jmp .done
    
.found:
    ; Display student info
    lea rdi, [rel student_found_fmt]
    mov esi, [rel student_id]
    lea rdx, [rel student_name]
    mov ecx, [rel student_grade]
    call _printf
    jmp .done
    
.no_students:
    lea rdi, [rel no_students_msg]
    call _printf
    
.done:
    pop rbp
    ret