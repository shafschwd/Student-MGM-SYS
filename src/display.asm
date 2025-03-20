; display.asm - Display student information
section .data
    ; Display formats
    header_msg db "===== Student List =====", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    student_info_fmt db "ID: %d, Name: %s, Grade: %d", 10, 0
    footer_msg db "=====================", 10, 0
    
    ; Constants
    ID_OFFSET equ 0                  ; Offset of ID field in record
    NAME_OFFSET equ 4                ; Offset of name field in record
    GRADE_OFFSET equ 54              ; Offset of grade field in record
    
section .text
    global _view_students
    extern _printf
    extern _get_student_count, _get_student_record
    
; Display all students
_view_students:
    push rbp
    mov rbp, rsp
    push rbx                    ; Save rbx as we'll use it
    
    ; Display header
    lea rdi, [rel header_msg]
    call _printf
    
    ; Check if there are any students
    call _get_student_count
    test eax, eax
    jz .no_students
    
    ; Save student count
    mov ebx, eax
    
    ; Loop through students
    mov r12d, 0                 ; Initialize counter
.display_loop:
    cmp r12d, ebx               ; Check if we've displayed all students
    jge .done
    
    ; Get student record
    mov edi, r12d
    call _get_student_record
    mov r13, rax                ; r13 = pointer to student record
    
    ; Display student info
    lea rdi, [rel student_info_fmt]
    mov esi, [r13 + ID_OFFSET]      ; Load ID
    lea rdx, [r13 + NAME_OFFSET]    ; Load name pointer
    mov ecx, [r13 + GRADE_OFFSET]   ; Load grade
    call _printf
    
    inc r12d                        ; Increment counter
    jmp .display_loop
    
    jmp .done
    
.no_students:
    lea rdi, [rel no_students_msg]
    call _printf
    
.done:
    ; Display footer
    lea rdi, [rel footer_msg]
    call _printf
    
    pop rbx                     ; Restore rbx
    pop rbp
    ret