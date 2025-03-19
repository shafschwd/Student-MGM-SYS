; records.asm - Student record management

section .data
    ; Constants
    MAX_STUDENTS equ 50
    RECORD_SIZE equ 100
    MAX_NAME_LENGTH equ 50
    MAX_SUBJECTS equ 5
    
    ; Prompts
    prompt_id db "Enter student ID: ", 0
    prompt_name db "Enter student name: ", 0
    prompt_subject db "Enter grade for subject %d: ", 0
    success_msg db "Student added successfully!", 10, 0
    full_msg db "Student database is full!", 10, 0
    search_prompt db "Enter student ID to search: ", 0
    not_found_msg db "Student not found!", 10, 0
    
section .bss
    ; Student records storage
    students resb MAX_STUDENTS * RECORD_SIZE
    student_count resd 1
    
    ; Temporary variables
    temp_id resd 1
    temp_name resb MAX_NAME_LENGTH
    temp_grades resd MAX_SUBJECTS
    
section .text
    global _add_student, _search_student, _get_student_count, _get_student_record
    extern _read_int, _read_string, _printf, _strcmp
    
; Structure of a student record in memory:
; Offset 0: ID (4 bytes)
; Offset 4: Name (50 bytes)
; Offset 54: Grades (5 subjects, 4 bytes each = 20 bytes)
; Offset 74: GPA (4 bytes)
; Total size: 78 bytes (rounded to 100 for simplicity)

; Function to add a student
_add_student:
    push rbp
    mov rbp, rsp
    
    ; Check if database is full
    mov eax, [rel student_count]
    cmp eax, MAX_STUDENTS
    jl .continue
    
    ; Database full
    lea rdi, [rel full_msg]
    xor eax, eax
    call _printf
    jmp .done
    
.continue:
    ; Get student ID
    lea rdi, [rel prompt_id]
    xor eax, eax
    call _printf
    call _read_int
    mov [rel temp_id], eax
    
    ; Get student name
    lea rdi, [rel prompt_name]
    xor eax, eax
    call _printf
    
    lea rdi, [rel temp_name]
    mov rsi, MAX_NAME_LENGTH
    call _read_string
    
    ; Get grades for each subject
    mov rcx, 0
.grade_loop:
    cmp rcx, MAX_SUBJECTS
    jge .store_record
    
    ; Prompt for subject grade
    lea rdi, [rel prompt_subject]
    mov rsi, rcx
    inc rsi
    xor eax, eax
    call _printf
    
    call _read_int
    mov rdx, rcx
    lea rcx, [rel temp_grades]
    mov [rcx + rdx*4], eax
    mov rcx, rdx
    
    inc rcx
    jmp .grade_loop
    
.store_record:
    ; Calculate offset for new record
    mov eax, [rel student_count]
    mov edx, RECORD_SIZE
    mul edx
    
    ; Store ID
    mov edx, [rel temp_id]
    lea rcx, [rel students]
    mov [rcx + rax], edx
    
    ; Store name (simple copy loop)
    lea rsi, [rel temp_name]
    lea rdi, [rel students + rax + 4]
    mov rcx, 0
.copy_name:
    cmp rcx, MAX_NAME_LENGTH
    jge .copy_name_done
    
    mov dl, [rsi + rcx]
    mov [rdi + rcx], dl
    test dl, dl
    jz .copy_name_done
    
    inc rcx
    jmp .copy_name
    
.copy_name_done:
    ; Store grades
    mov rcx, 0
.copy_grades:
    cmp rcx, MAX_SUBJECTS
    jge .finish_record
    
    mov rdx, rcx
    lea r9, [rel temp_grades]
    mov edx, [r9 + rdx*4]
    lea r8, [rel students]
    mov [r8 + rax + 54 + rcx*4], edx
    
    inc rcx
    jmp .copy_grades
    
.finish_record:
    ; Initialize GPA to 0
    lea rcx, [rel students]
    mov dword [rcx + rax + 74], 0
    
    ; Increment student count
    inc dword [rel student_count]
    
    ; Display success message
    lea rdi, [rel success_msg]
    xor eax, eax
    call _printf
    
.done:
    pop rbp
    ret

; Function to search for a student by ID
; Returns: rax = pointer to student record or 0 if not found
_search_student:
    push rbp
    mov rbp, rsp
    
    ; Prompt for ID to search
    lea rdi, [rel search_prompt]
    xor eax, eax
    call _printf
    
    call _read_int
    mov [rel temp_id], eax
    
    ; Search through records
    mov rcx, 0
.search_loop:
    cmp rcx, [rel student_count]
    jge .not_found
    
    ; Calculate offset for current record
    mov rax, rcx
    mov rdx, RECORD_SIZE
    mul rdx
    
    ; Compare ID
    lea rdx, [rel students]
    mov edi, [rdx + rax]
    cmp edi, [rel temp_id]
    je .found
    
    inc rcx
    jmp .search_loop
    
.found:
    ; Return pointer to record
    lea rax, [rel students + rax]
    jmp .done
    
.not_found:
    lea rdi, [rel not_found_msg]
    xor eax, eax
    call _printf
    xor rax, rax    ; Return NULL
    
.done:
    pop rbp
    ret

; Function to get student count
; Returns: eax = number of students
_get_student_count:
    mov eax, [rel student_count]
    ret
    
; Function to get student record by index
; Parameters: rdi = index
; Returns: rax = pointer to student record
_get_student_record:
    mov rax, rdi
    mov rdx, RECORD_SIZE
    mul rdx
    lea rax, [rel students + rax]
    ret