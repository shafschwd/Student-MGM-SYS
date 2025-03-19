; calculations.asm - Grade calculation logic

section .data
    prompt_calc_id db "Enter student ID to calculate GPA: ", 0
    calc_success_msg db "GPA calculated successfully!", 10, 0
    
section .text
    global calculate_gpa
    extern read_int, _printf, search_student
    
; Function to calculate GPA for a student
calculate_gpa:
    push rbp
    mov rbp, rsp
    
    ; Get student ID
    lea rdi, [rel prompt_calc_id]
    xor eax, eax
    call _printf
    
    ; Search for student
    call search_student
    test rax, rax
    jz .done      ; Student not found
    
    ; Found the student, calculate GPA
    mov rbx, rax  ; Store student record pointer
    
    ; Calculate sum of grades
    xor rcx, rcx
    xorps xmm0, xmm0      ; Clear accumulator
.sum_loop:
    cmp rcx, 5            ; 5 subjects
    jge .calc_average
    
    ; Add current grade to sum
    movss xmm1, [rbx + 54 + rcx*4]
    addss xmm0, xmm1
    
    inc rcx
    jmp .sum_loop
    
.calc_average:
    ; Divide by number of subjects
    mov ecx, 5
    cvtsi2ss xmm1, ecx
    divss xmm0, xmm1
    
    ; Store result in student record
    movss [rbx + 74], xmm0
    
    ; Display success message
    lea rdi, [rel calc_success_msg]
    xor eax, eax
    call _printf
    
.done:
    pop rbp
    ret