; main.asm - Main entry point with full menu functionality
bits 64

section .data
    welcome_msg db "===== Student Grade Management System =====", 10, 0
    loading_msg db "Loading students...", 10, 0
    menu_msg db "1. Add Student", 10, "2. View Students", 10, "3. Calculate GPA (Average of 4 Subjects)", 10, "4. Search Student", 10, "5. Exit", 10, "Enter choice: ", 0
    invalid_msg db "Invalid choice. Please try again.", 10, 0
    exit_msg db "Exiting program. Goodbye!", 10, 0
    fmt_int db "%d", 0
    
section .bss
    choice resd 1  ; 4 bytes for storing user's menu choice
    
section .text
    global main
    extern printf, scanf, exit
    extern load_students_from_file
    extern add_student, view_students, calculate_gpa, search_student
    extern flush_input
    
main:
    push rbp
    mov rbp, rsp
    
    ; Display welcome message
    lea rdi, [rel welcome_msg]
    xor eax, eax
    call printf
    
    ; Load students
    lea rdi, [rel loading_msg]
    xor eax, eax
    call printf
    
    call load_students_from_file
    
main_loop:
    ; Display menu
    lea rdi, [rel welcome_msg]
    xor eax, eax
    call printf
    
    lea rdi, [rel menu_msg]
    xor eax, eax
    call printf
    
    ; Read user choice
    lea rdi, [rel fmt_int]
    lea rsi, [rel choice]
    xor eax, eax
    call scanf
    
    ; Clear input buffer
    call flush_input
    
    ; Process choice
    mov eax, [rel choice]
    
    ; Option 1: Add Student
    cmp eax, 1
    je .add_student
    
    ; Option 2: View Students
    cmp eax, 2
    je .view_students
    
    ; Option 3: Calculate GPA
    cmp eax, 3
    je .calculate_gpa
    
    ; Option 4: Search Student
    cmp eax, 4
    je .search_student
    
    ; Option 5: Exit
    cmp eax, 5
    je .exit
    
    ; Invalid choice
    lea rdi, [rel invalid_msg]
    xor eax, eax
    call printf
    jmp main_loop
    
.add_student:
    call add_student
    jmp main_loop
    
.view_students:
    call view_students
    jmp main_loop
    
.calculate_gpa:
    call calculate_gpa
    jmp main_loop
    
.search_student:
    call search_student
    jmp main_loop
    
.exit:
    ; Display exit message
    lea rdi, [rel exit_msg]
    xor eax, eax
    call printf
    
    ; Exit with status code 0
    xor edi, edi
    call exit
    
    ; Should never reach here, but just in case
    xor eax, eax
    leave
    ret