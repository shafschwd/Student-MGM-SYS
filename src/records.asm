; records.asm - Super simplified for macOS
section .data
    ; Constants
    MAX_STUDENTS equ 10
    
    ; Prompts
    prompt_id db "Enter student ID: ", 0
    prompt_name db "Enter student name: ", 0
    prompt_grade db "Enter grade for subject %d: ", 0
    success_msg db "Student added successfully!", 10, 0
    max_students_msg db "Maximum number of students reached!", 10, 0
    
    ; Formats
    fmt_int db "%d", 0
    fmt_str db "%s", 0
    fmt_print db "Added student - ID: %d, Name: %s, Grade: %d", 10, 0
    
    ; Counter
    student_count dd 0
    
section .bss
    ; Arrays for student data
    student_ids resd MAX_STUDENTS      ; Array of IDs (4 bytes each)
    student_names resb MAX_STUDENTS * 50  ; Array of names (50 bytes each)
    student_grades resd MAX_STUDENTS   ; Array of grades (4 bytes each)
    
    ; Temp variables
    temp_id resd 1
    temp_name resb 50
    temp_grade resd 1
    
section .text
    global _add_student
    global _get_student_count
    global _get_student_record
    extern _printf, _scanf, _flush_input
    
; Add student record
_add_student:
    push rbp
    mov rbp, rsp
    
    ; Check if we've reached maximum students
    mov eax, [rel student_count]
    cmp eax, MAX_STUDENTS
    jl .continue
    
    ; Maximum reached
    lea rdi, [rel max_students_msg]
    xor eax, eax
    call _printf
    jmp .done
    
.continue:
    ; Get student ID
    lea rdi, [rel prompt_id]
    xor eax, eax
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel temp_id]
    xor eax, eax
    call _scanf
    
    call _flush_input
    
    ; Get student name
    lea rdi, [rel prompt_name]
    xor eax, eax
    call _printf
    
    lea rdi, [rel fmt_str]
    lea rsi, [rel temp_name]
    xor eax, eax
    call _scanf
    
    call _flush_input
    
    ; Get grade
    lea rdi, [rel prompt_grade]
    mov rsi, 1
    xor eax, eax
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel temp_grade]
    xor eax, eax
    call _scanf
    
    call _flush_input
    
    ; Get current index
    mov r8d, [rel student_count]
    
    ; Store ID (simple way)
    lea r10, [rel student_ids]
    mov eax, [rel temp_id]
    mov [r10 + r8*4], eax
    
    ; Store name (careful with string)
    lea r10, [rel student_names]  ; Base address
    mov r9, r8                   ; Copy index
    imul r9, 50                  ; r9 = index * 50
    add r10, r9                  ; Address = base + (index * 50)
    
    ; Copy name (char by char)
    mov rcx, 0
.copy_loop:
    cmp rcx, 49                  ; Max length - 1
    jge .end_copy
    
    mov al, byte [rel temp_name + rcx]
    mov byte [r10 + rcx], al
    
    test al, al                  ; Check for null terminator
    jz .end_copy
    
    inc rcx
    jmp .copy_loop
    
.end_copy:
    mov byte [r10 + rcx], 0      ; Ensure null termination
    
    ; Store grade (simple way)
    lea r10, [rel student_grades]
    mov eax, [rel temp_grade]
    mov [r10 + r8*4], eax
    
    ; Increment count
    inc dword [rel student_count]
    
    ; Display success
    lea rdi, [rel success_msg]
    xor eax, eax
    call _printf
    
    lea rdi, [rel fmt_print]
    mov esi, [rel temp_id]
    lea rdx, [rel temp_name]
    mov ecx, [rel temp_grade]
    xor eax, eax
    call _printf
    
.done:
    pop rbp
    ret

; Get student count
_get_student_count:
    mov eax, [rel student_count]
    ret

; Get student by index - simplified to return ID, then call other functions
_get_student_record:
    ; Check if index is valid
    cmp edi, [rel student_count]
    jge .invalid
    
    mov eax, edi    ; Just return the index for now
    ret
    
.invalid:
    mov eax, -1
    ret

; These are added functions to work with our simplified structure
global _get_student_id, _get_student_name, _get_student_grade

; Get ID for student at index
_get_student_id:
    ; Check if index is valid
    cmp edi, [rel student_count]
    jge .invalid
    
    ; Calculate address
    lea r10, [rel student_ids]
    mov eax, [r10 + rdi*4]
    ret
    
.invalid:
    mov eax, -1
    ret

; Get pointer to name for student at index
_get_student_name:
    ; Check if index is valid
    cmp edi, [rel student_count]
    jge .invalid
    
    ; Calculate name address
    lea r10, [rel student_names]
    mov rax, rdi
    imul rax, 50
    add rax, r10
    ret
    
.invalid:
    xor eax, eax
    ret

; Get grade for student at index
_get_student_grade:
    ; Check if index is valid
    cmp edi, [rel student_count]
    jge .invalid
    
    ; Calculate address
    lea r10, [rel student_grades]
    mov eax, [r10 + rdi*4]
    ret
    
.invalid:
    mov eax, -1
    ret