; search.asm - Student search functionality
section .data
    ; Messages
    search_header db "===== Student Search =====", 10, 0
    search_prompt db "Enter student ID to search: ", 0
    student_found_fmt db "Student found!", 10, "ID: %d, Name: %s, Grade: %d", 10, 0
    student_not_found db "Student with ID %d not found.", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    fmt_int db "%d", 0
    
    ; Constants
    ID_OFFSET equ 0                  ; Offset of ID field in record
    NAME_OFFSET equ 4                ; Offset of name field in record
    GRADE_OFFSET equ 54              ; Offset of grade field in record
    
section .bss
    search_id resd 1       ; Buffer for search ID
    
section .text
    global _search_student
    extern _printf, _scanf, _flush_input
    extern _get_student_count, _get_student_record
    
; Search for a student by ID
_search_student:
    push rbp
    mov rbp, rsp
    push rbx                    ; Save rbx as we'll use it
    
    ; Display header
    lea rdi, [rel search_header]
    call _printf
    
    ; Check if there are any students
    call _get_student_count
    test eax, eax
    jz .no_students
    
    ; Save student count
    mov ebx, eax
    
    ; Prompt for ID to search
    lea rdi, [rel search_prompt]
    call _printf
    
    ; Read ID
    lea rdi, [rel fmt_int]
    lea rsi, [rel search_id]
    call _scanf
    
    call _flush_input
    
    ; Search through all students
    mov r12d, 0                 ; Initialize counter
.search_loop:
    cmp r12d, ebx               ; Check if we've searched all students
    jge .not_found
    
    ; Get student record
    mov edi, r12d
    call _get_student_record
    mov r13, rax                ; r13 = pointer to student record
    
    ; Compare IDs
    mov eax, [rel search_id]
    cmp eax, [r13 + ID_OFFSET]
    je .found
    
    inc r12d                    ; Increment counter
    jmp .search_loop
    
.found:
    ; Display student info
    lea rdi, [rel student_found_fmt]
    mov esi, [r13 + ID_OFFSET]      ; Load ID
    lea rdx, [r13 + NAME_OFFSET]    ; Load name pointer
    mov ecx, [r13 + GRADE_OFFSET]   ; Load grade
    call _printf
    jmp .done
    
.not_found:
    ; Not found
    lea rdi, [rel student_not_found]
    mov esi, [rel search_id]
    call _printf
    jmp .done
    
.no_students:
    lea rdi, [rel no_students_msg]
    call _printf
    
.done:
    pop rbx                     ; Restore rbx
    pop rbp
    ret