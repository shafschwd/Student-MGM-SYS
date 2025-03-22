; calculations.asm - Math functions for student data processing
bits 64

section .data
    ; Prompts and messages
    gpa_prompt db "Enter student ID to calculate GPA: ", 0
    gpa_result db "Student %d (%s) GPA: %d.%d", 10, 0
    not_found_msg db "Student with ID %d not found.", 10, 0
    
    ; Format for reading input
    fmt_int db "%d", 0

section .bss
    student_id resd 1   ; For storing input student ID

section .text
    global calculate_gpa
    extern printf, scanf, flush_input
    extern get_student_count, get_student_id, get_student_name
    extern calculate_student_avg

; Calculate and display GPA (average of all grades) for a student
calculate_gpa:
    push rbp
    mov rbp, rsp
    
    ; Prompt for student ID
    lea rdi, [rel gpa_prompt]
    xor eax, eax
    call printf
    
    ; Read student ID
    lea rdi, [rel fmt_int]
    lea rsi, [rel student_id]
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Find student with this ID
    mov r12d, [rel student_id]  ; Student ID to find
    
    ; Get total number of students
    call get_student_count
    mov r13d, eax               ; Total student count
    
    ; Loop through students to find the one with the requested ID
    xor r14d, r14d              ; Student index
    
.search_loop:
    ; Check if we've checked all students
    cmp r14d, r13d
    jge .not_found
    
    ; Get ID of current student
    mov edi, r14d
    call get_student_id
    
    ; Compare with the ID we're looking for
    cmp eax, r12d
    je .found
    
    ; Check next student
    inc r14d
    jmp .search_loop
    
.found:
    ; Found the student, get name
    mov edi, r14d
    call get_student_name
    
    ; Save the student name pointer
    mov rbx, rax
    
    ; Calculate average grade (GPA) - now returns GPA × 10
    mov edi, r14d
    call calculate_student_avg
    
    ; Split into whole number and decimal
    mov ecx, 10
    cdq                  ; Sign extend eax into edx:eax
    idiv ecx             ; eax = whole number, edx = decimal
    
    ; Display the GPA with decimal point
    lea rdi, [rel gpa_result]
    mov esi, r12d        ; Student ID
    mov rdx, rbx         ; Student name
    mov ecx, eax         ; Whole number part
    mov r8d, edx         ; Decimal part
    xor eax, eax
    call printf
    
    pop rbp
    ret
    
.not_found:
    ; Student not found, display error
    lea rdi, [rel not_found_msg]
    mov esi, r12d        ; Student ID
    xor eax, eax
    call printf
    
    pop rbp
    ret
