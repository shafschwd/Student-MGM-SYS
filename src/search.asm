; search.asm - Search functionality for students
bits 64

section .data
    ; Prompts and messages
    search_prompt db "Enter student ID to search: ", 0
    not_found_msg db "Student with ID %d not found.", 10, 0
    
    ; Student info display formats
    student_info_fmt db "Student ID: %d", 10, "Name: %s", 10, 0
    grade_fmt db "Grade for subject %d: %d", 10, 0
    average_fmt db "Average grade: %d", 10, 0
    
    ; Format for reading input
    fmt_int db "%d", 0

section .bss
    student_id resd 1   ; For storing input student ID

section .text
    global search_student
    extern printf, scanf, flush_input
    extern get_student_count, get_student_id, get_student_name
    extern get_student_grade, calculate_student_avg

; Search for a student by ID and display their information
search_student:
    push rbp
    mov rbp, rsp
    
    ; Prompt for student ID
    lea rdi, [rel search_prompt]
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
    ; Found the student, display their information
    
    ; Get and display student name
    mov edi, r14d
    call get_student_name
    
    ; Save the student name pointer
    mov rbx, rax
    
    ; Display basic student info
    lea rdi, [rel student_info_fmt]
    mov esi, r12d        ; Student ID
    mov rdx, rbx         ; Student name
    xor eax, eax
    call printf
    
    ; Display grades for all subjects
    xor r15d, r15d       ; Subject counter
    
.grade_loop:
    ; Check if we've displayed all subjects
    cmp r15d, 4          ; 4 subjects
    jge .done_grades
    
    ; Get grade for this subject
    mov edi, r14d        ; Student index
    mov esi, r15d        ; Subject index
    call get_student_grade
    
    ; Save the grade
    mov ebx, eax
    
    ; Display the grade
    lea rdi, [rel grade_fmt]
    lea esi, [r15d+1]    ; 1-based subject number
    mov edx, ebx         ; Grade
    xor eax, eax
    call printf
    
    ; Next subject
    inc r15d
    jmp .grade_loop
    
.done_grades:
    ; Calculate and display average grade
    mov edi, r14d
    call calculate_student_avg
    
    ; Display the average
    lea rdi, [rel average_fmt]
    mov esi, eax         ; Average grade
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