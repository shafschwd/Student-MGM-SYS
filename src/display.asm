; display.asm - Show multiple students with their grades (simplified version)
bits 64    ; Explicitly set 64-bit mode

section .data
    ; Display formats
    header_msg db "===== Student List =====", 10, 0
    no_students_msg db "No students in the database.", 10, 0
    count_msg db "Total students: %d", 10, 0
    student_info_fmt db "Student #%d - ID: %d, Name: %s", 10, 0
    
    ; Individual grade format strings for maximum simplicity
    math_fmt db "  Math: %d", 10, 0
    science_fmt db "  Science: %d", 10, 0
    english_fmt db "  English: %d", 10, 0
    history_fmt db "  History: %d", 10, 0
    
    footer_msg db "=====================", 10, 0
    null_str db "(null)", 0
    
section .text
    global view_students
    extern printf
    extern get_student_count
    extern get_student_id
    extern get_student_name
    extern get_student_grade
    
; Ultra simplified student display - show each student with 4 grades
view_students:
    push rbp
    mov rbp, rsp
    
    ; Display header
    lea rdi, [rel header_msg]
    xor eax, eax
    call printf
    
    ; Get student count
    call get_student_count
    
    ; Display count
    lea rdi, [rel count_msg]
    mov esi, eax
    xor eax, eax
    call printf
    
    ; Save student count
    mov r12d, eax
    
    ; Check if we have any students
    test r12d, r12d
    jz .no_students
    
    ; Loop through all students
    xor r14d, r14d       ; Student index counter
    
.display_loop:
    ; Check if we've processed all students
    cmp r14d, r12d
    jge .display_done
    
    ; Get student ID
    mov edi, r14d
    call get_student_id
    
    ; Skip if ID is negative
    cmp eax, 0
    jl .next_student
    
    ; Save ID
    mov r15d, eax
    
    ; Get student name
    mov edi, r14d
    call get_student_name
    
    ; Check if name is valid
    mov rbx, rax
    test rbx, rbx
    jnz .name_valid
    lea rbx, [rel null_str]
    
.name_valid:
    ; Display basic student info
    lea rdi, [rel student_info_fmt]
    lea esi, [r14d+1]    ; 1-based display
    mov edx, r15d        ; ID
    mov rcx, rbx         ; Name
    xor eax, eax
    call printf
    
    ; Add a comment here to indicate the correct order for subject display
    ; The grades should be displayed in this order:
    ;   Math (index 0)
    ;   Science (index 1)
    ;   English (index 2)
    ;   History (index 3)
    
    ; Display Math grade (subject 0)
    mov edi, r14d
    xor esi, esi        ; Subject 0
    call get_student_grade
    push rax            ; Save grade
    
    lea rdi, [rel math_fmt]
    pop rsi             ; Get grade as parameter
    xor eax, eax
    call printf
    
    ; Display Science grade (subject 1)
    mov edi, r14d
    mov esi, 1          ; Subject 1
    call get_student_grade
    push rax            ; Save grade
    
    lea rdi, [rel science_fmt]
    pop rsi             ; Get grade as parameter
    xor eax, eax
    call printf
    
    ; Display English grade (subject 2)
    mov edi, r14d
    mov esi, 2          ; Subject 2
    call get_student_grade
    push rax            ; Save grade
    
    lea rdi, [rel english_fmt]
    pop rsi             ; Get grade as parameter
    xor eax, eax
    call printf
    
    ; Display History grade (subject 3)
    mov edi, r14d
    mov esi, 3          ; Subject 3
    call get_student_grade
    push rax            ; Save grade
    
    lea rdi, [rel history_fmt]
    pop rsi             ; Get grade as parameter
    xor eax, eax
    call printf
    
.next_student:
    inc r14d
    jmp .display_loop
    
.no_students:
    lea rdi, [rel no_students_msg]
    xor eax, eax
    call printf
    
.display_done:
    lea rdi, [rel footer_msg]
    xor eax, eax
    call printf
    
    pop rbp
    ret