; display.asm - Show multiple students safely
bits 64    ; Explicitly set 64-bit mode

section .data
    ; Display formats
    header_msg db "===== Student List =====", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    count_msg db "Total students: %d", 10, 0
    student_info_fmt db "Student #%d - ID: %d, Name: %s, Grade: %d", 10, 0
    footer_msg db "=====================", 10, 0
    null_str db "(null)", 0
    valid_fmt db "Valid students: %d", 10, 0
    
section .text
    global view_students
    extern printf
    extern get_student_count
    extern get_student_id
    extern get_student_name
    extern get_student_grade
    
; Clean version - only show valid students
view_students:
    ; Standard prologue
    push rbp
    mov rbp, rsp
    
    ; Save callee-saved registers
    push r12
    push r13
    push r14
    push r15
    
    ; Display header
    lea rdi, [rel header_msg]
    xor eax, eax
    call printf
    
    ; Get student count
    call get_student_count
    mov r12d, eax        ; Save student count in r12d
    
    ; Display total count
    lea rdi, [rel count_msg]
    mov esi, r12d
    xor eax, eax
    call printf
    
    ; Check if we have any students
    test r12d, r12d
    jz .no_students
    
    ; First pass: count valid students (ID >= 0)
    xor r13d, r13d       ; Initialize valid student counter to 0
    xor r14d, r14d       ; Initialize index counter to 0
    
.count_valid_loop:
    ; Check if we've checked all students
    cmp r14d, r12d
    jge .count_valid_done
    
    ; Get student ID
    mov edi, r14d
    call get_student_id
    
    ; Check if student is valid (ID >= 0)
    cmp eax, 0
    jl .skip_invalid
    
    ; Valid student found, increment counter
    inc r13d
    
.skip_invalid:
    ; Move to next student
    inc r14d
    jmp .count_valid_loop
    
.count_valid_done:
    ; Display valid student count
    lea rdi, [rel valid_fmt]
    mov esi, r13d
    xor eax, eax
    call printf
    
    ; Check if we have any valid students
    test r13d, r13d
    jz .no_students
    
    ; Second pass: display valid students
    xor r14d, r14d       ; Reset index counter to 0
    xor r15d, r15d       ; Reset valid student index (for display numbering)
    
.display_loop:
    ; Check if we've checked all students
    cmp r14d, r12d
    jge .display_done
    
    ; Get student ID
    mov edi, r14d
    call get_student_id
    
    ; Check if student is valid (ID >= 0)
    cmp eax, 0
    jl .next_student
    
    ; Save ID for display
    mov ebx, eax
    
    ; Get student name
    mov edi, r14d
    call get_student_name
    
    ; Save pointer and check if NULL
    mov r13, rax
    test r13, r13
    jnz .name_valid
    lea r13, [rel null_str]
    
.name_valid:
    ; Get student grade
    mov edi, r14d
    call get_student_grade
    
    ; Print student info (only for valid students)
    lea rdi, [rel student_info_fmt]
    lea esi, [r15d+1]    ; Student number (1-based)
    mov edx, ebx         ; Student ID
    mov rcx, r13         ; Student name
    mov r8d, eax         ; Student grade
    xor eax, eax
    call printf
    
    ; Increment valid student counter
    inc r15d
    
.next_student:
    ; Move to next student
    inc r14d
    jmp .display_loop
    
.no_students:
    ; Display no students message
    lea rdi, [rel no_students_msg]
    xor eax, eax
    call printf
    
.display_done:
    ; Display footer
    lea rdi, [rel footer_msg]
    xor eax, eax
    call printf
    
    ; Restore callee-saved registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret