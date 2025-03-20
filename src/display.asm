; display.asm - Display student information
section .data
    ; Display formats
    header_msg db "===== Student List =====", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    student_info_fmt db "ID: %d, Name: %s, Grade: %d", 10, 0
    footer_msg db "=====================", 10, 0
    
section .text
    global _view_students
    extern _printf
    extern _get_student_count, _get_student_id, _get_student_name, _get_student_grade
    
; Display all students
_view_students:
    push rbp
    mov rbp, rsp
    push rbx                    ; Save non-volatile registers
    push r12
    push r13
    push r14
    push r15
    
    ; Display header
    lea rdi, [rel header_msg]
    xor eax, eax
    call _printf
    
    ; Check if there are any students
    call _get_student_count
    test eax, eax
    jz .no_students
    
    ; Save student count
    mov ebx, eax
    
    ; Loop through students
    xor r12d, r12d                 ; Initialize counter
.display_loop:
    cmp r12d, ebx                  ; Check if we've displayed all students
    jge .done
    
    ; Get student ID
    mov edi, r12d
    call _get_student_id
    mov r13d, eax                  ; r13d = student ID
    
    ; Get student name pointer
    mov edi, r12d
    call _get_student_name
    mov r14, rax                   ; r14 = pointer to student name
    
    ; Get student grade
    mov edi, r12d
    call _get_student_grade
    mov r15d, eax                  ; r15d = student grade
    
    ; Display student info
    lea rdi, [rel student_info_fmt]
    mov esi, r13d                  ; ID
    mov rdx, r14                   ; Name pointer
    mov ecx, r15d                  ; Grade
    xor eax, eax
    call _printf
    
    inc r12d                       ; Increment counter
    jmp .display_loop
    
.no_students:
    lea rdi, [rel no_students_msg]
    xor eax, eax
    call _printf
    
.done:
    ; Display footer
    lea rdi, [rel footer_msg]
    xor eax, eax
    call _printf
    
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    
    pop rbp
    ret