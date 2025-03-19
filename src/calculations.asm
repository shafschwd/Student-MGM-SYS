; calculations.asm - GPA calculations
section .data
    ; Messages
    gpa_header db "===== GPA Calculation =====", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    gpa_result_msg db "Student ID: %d, Name: %s", 10, "Grade: %d, GPA: %.2f", 10, 0
    
section .text
    global _calculate_gpa
    extern _printf
    extern student_count, student_id, student_name, student_grade
    
; Calculate GPA (simplified version)
_calculate_gpa:
    push rbp
    mov rbp, rsp
    
    ; Display header
    lea rdi, [rel gpa_header]
    call _printf
    
    ; Check if there are any students
    mov eax, [rel student_count]
    cmp eax, 0
    je .no_students
    
    ; Simple GPA calculation (grade / 20) just for demonstration
    ; In a real system, you'd have a more complex formula based on multiple grades
    mov eax, [rel student_grade]
    cvtsi2ss xmm0, eax    ; Convert to float
    movss xmm1, [rel divisor]
    divss xmm0, xmm1      ; Divide by 20 to get a GPA between 0-5
    
    ; Display the student info with GPA
    lea rdi, [rel gpa_result_msg]
    mov esi, [rel student_id]
    lea rdx, [rel student_name]
    mov ecx, [rel student_grade]
    ; xmm0 already contains our GPA
    cvtss2sd xmm0, xmm0   ; Convert to double for printf
    mov al, 1             ; 1 floating point argument
    call _printf
    
    jmp .done
    
.no_students:
    lea rdi, [rel no_students_msg]
    call _printf
    
.done:
    pop rbp
    ret

section .data
    divisor dd 20.0       ; Divisor for GPA calculation