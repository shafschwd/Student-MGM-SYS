; main.asm - Main entry point for Student Record Management System
section .data
    title_msg db "===== Student Record Management System =====", 10, 0
    menu_msg db "1. Add Student", 10, "2. View Students", 10, "3. Calculate GPA", 10, "4. Search Student", 10, "5. Exit", 10, "Enter choice: ", 0
    invalid_msg db "Invalid choice. Please try again.", 10, 0
    exit_msg db "Exiting program. Goodbye!", 10, 0
    fmt_int db "%d", 0
    
section .bss
    choice resb 4
    
section .text
    global _main
    global _flush_input    ; Export flush_input
    extern _printf, _scanf, _getchar
    extern _add_student
    extern _view_students  ; Add this external reference
    extern _calculate_gpa     ; Add this external reference
    extern _search_student     ; Add this external reference

_main:
    push rbp
    mov rbp, rsp
    
main_loop:
    ; Display title and menu
    lea rdi, [rel title_msg]
    call _printf
    
    lea rdi, [rel menu_msg]
    call _printf
    
    ; Read choice
    lea rdi, [rel fmt_int]
    lea rsi, [rel choice]
    call _scanf
    
    ; Clear input buffer
    call _flush_input
    
    ; Process choice
    mov eax, [rel choice]
    
    cmp eax, 1
    je menu_add_student
    
    cmp eax, 2
    je menu_view_students
    
    cmp eax, 3
    je menu_calculate_gpa
    
    cmp eax, 4
    je menu_search_student
    
    cmp eax, 5
    je menu_exit
    
    ; Invalid choice
    lea rdi, [rel invalid_msg]
    call _printf
    jmp main_loop
    
menu_add_student:
    call _add_student
    jmp main_loop
    
menu_view_students:
    call _view_students    ; Call our new view_students function
    jmp main_loop
    
menu_calculate_gpa:
    call _calculate_gpa    ; Call our calculate_gpa function
    jmp main_loop
    
menu_search_student:
    call _search_student    ; Call our search_student function
    jmp main_loop
    
menu_exit:
    lea rdi, [rel exit_msg]
    call _printf
    
    mov rax, 0
    pop rbp
    ret

; Flush input buffer
_flush_input:
    push rbp
    mov rbp, rsp
    
.loop:
    call _getchar
    cmp al, 10          ; Newline
    je .done
    cmp al, -1          ; EOF
    je .done
    jmp .loop
    
.done:
    pop rbp
    ret