; main.asm - Main entry point for Student Record Management System

section .data
    ; Menu strings
    title_msg db "===== Student Record Management System =====", 10, 0
    menu_msg db 10, "1. Add Student", 10, "2. View Students", 10, "3. Calculate GPA", 10, "4. Search Student", 10, "5. Exit", 10, 10, "Enter your choice: ", 0
    invalid_msg db "Invalid choice! Please try again.", 10, 0
    exit_msg db "Exiting program. Goodbye!", 10, 0
    
section .bss
    choice resb 2   ; Buffer for user choice input
    
section .text
    global _main
    extern _printf, _scanf
    
    ; External functions from other files
    extern read_string, read_int
    extern display_student, display_all_students
    extern calculate_gpa
    extern add_student, search_student
    
_main:
    push rbp
    mov rbp, rsp
    
main_loop:
    ; Display title
    lea rdi, [rel title_msg]
    xor eax, eax
    call _printf
    
    ; Display menu
    lea rdi, [rel menu_msg]
    xor eax, eax
    call _printf
    
    ; Read user choice
    lea rdi, [rel choice]
    mov rsi, 2
    call read_string
    
    ; Convert choice to integer
    movzx eax, byte [choice]
    sub eax, '0'
    
    ; Jump to appropriate function based on choice
    cmp eax, 1
    je .add_student_section
    
    cmp eax, 2
    je .view_students_section
    
    cmp eax, 3
    je .calculate_gpa_section
    
    cmp eax, 4
    je .search_section
    
    cmp eax, 5
    je .exit_section
    
    ; Invalid choice
    lea rdi, [rel invalid_msg]
    xor eax, eax
    call _printf
    jmp main_loop
    
.add_student_section:
    call add_student
    jmp main_loop
    
.view_students_section:
    call display_all_students
    jmp main_loop
    
.calculate_gpa_section:
    call calculate_gpa
    jmp main_loop
    
.search_section:
    call search_student
    jmp main_loop
    
.exit_section:
    lea rdi, [rel exit_msg]
    xor eax, eax
    call _printf
    
    xor eax, eax
    pop rbp
    ret