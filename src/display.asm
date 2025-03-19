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
    extern student_count, student_id, student_name, student_grade
    
; Display all students (currently just the latest one)
_view_students:
    push rbp
    mov rbp, rsp
    
    ; Display header
    lea rdi, [rel header_msg]
    call _printf
    
    ; Check if there are any students
    mov eax, [rel student_count]
    cmp eax, 0
    je .no_students
    
    ; Display the student info
    lea rdi, [rel student_info_fmt]
    mov esi, [rel student_id]
    lea rdx, [rel student_name]
    mov ecx, [rel student_grade]
    call _printf
    
    jmp .done
    
.no_students:
    lea rdi, [rel no_students_msg]
    call _printf
    
.done:
    ; Display footer
    lea rdi, [rel footer_msg]
    call _printf
    
    pop rbp
    ret