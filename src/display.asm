; display.asm - Output routines

section .data
    ; Display formats
    header_fmt db "ID    Name                                  GPA", 10, "------------------------------------------------", 10, 0
    student_fmt db "%4d  %-40s  %.2f", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    
section .text
    global _display_student, _display_all_students
    extern _printf, _get_student_count, _get_student_record
    
; Function to display a single student
; Parameters:
;   rdi = pointer to student record
_display_student:
    push rbp
    mov rbp, rsp
    
    ; Preserve student record pointer
    push rdi
    
    ; Display student info
    ; Format: ID, Name, GPA
    lea rdi, [rel student_fmt]
    mov rsi, [rbp-8]     ; ID (first 4 bytes of record)
    mov edx, [rsi]
    lea rcx, [rsi+4]     ; Name (offset 4)
    movss xmm0, [rsi+74] ; GPA (offset 74)
    cvtss2sd xmm0, xmm0  ; Convert to double for printf
    mov rax, 1           ; 1 floating point argument
    call _printf
    
    pop rdi
    pop rbp
    ret
    
; Function to display all students
_display_all_students:
    push rbp
    mov rbp, rsp
    
    ; Get student count
    call _get_student_count
    test eax, eax
    jz .no_students
    
    ; Display header
    lea rdi, [rel header_fmt]
    xor eax, eax
    call _printf
    
    ; Loop through all students
    mov rbx, 0      ; Counter
.display_loop:
    cmp ebx, eax
    jge .done
    
    ; Get student record
    mov rdi, rbx
    call _get_student_record
    
    ; Display it
    mov rdi, rax
    call _display_student
    
    inc rbx
    jmp .display_loop
    
.no_students:
    lea rdi, [rel no_students_msg]
    xor eax, eax
    call _printf
    
.done:
    pop rbp
    ret