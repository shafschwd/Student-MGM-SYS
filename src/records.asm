; records_minimal.asm - Extremely minimal student record management for macOS
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
    
    ; Student data (global variables)
    global _student_count
    _student_count: dd 0
    
section .bss
    global _student_ids, _student_names, _student_grades
    _student_ids: resd MAX_STUDENTS
    _student_names: resb MAX_STUDENTS * 50
    _student_grades: resd MAX_STUDENTS
    
    ; Temporary variables
    temp_id: resd 1
    temp_name: resb 50
    temp_grade: resd 1
    
section .text
    global _add_student
    extern _printf, _scanf, _flush_input
    
; Add student record
_add_student:
    push rbp
    mov rbp, rsp
    
    ; Check if we've reached maximum students
    mov eax, [rel _student_count]
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
    
    ; Get current student index
    mov r12d, [rel _student_count]
    
    ; Store the ID
    mov rax, r12                ; Current index 
    mov rbx, 4                  ; Size of ID
    mul rbx                     ; rax = index * 4
    lea rdi, [rel _student_ids] ; Base address
    add rdi, rax                ; Address to store ID
    mov eax, [rel temp_id]      ; Load ID value
    mov [rdi], eax              ; Store ID 
    
    ; Store the grade similarly
    mov rax, r12                ; Current index 
    mov rbx, 4                  ; Size of grade
    mul rbx                     ; rax = index * 4
    lea rdi, [rel _student_grades] ; Base address
    add rdi, rax                ; Address to store grade
    mov eax, [rel temp_grade]   ; Load grade value
    mov [rdi], eax              ; Store grade
    
    ; Store the name (byte by byte)
    mov rax, r12                ; Current index
    mov rbx, 50                 ; Size of name
    mul rbx                     ; rax = index * 50
    lea rdi, [rel _student_names] ; Base address
    add rdi, rax                ; Target address
    lea rsi, [rel temp_name]    ; Source address
    
    ; Copy the name characters one by one
    mov rcx, 0                  ; Counter
.name_loop:
    cmp rcx, 49                 ; Max length - 1
    jge .end_name
    
    mov al, [rsi + rcx]         ; Get character
    mov [rdi + rcx], al         ; Store character
    
    test al, al                 ; Check for null
    jz .end_name
    
    inc rcx
    jmp .name_loop
    
.end_name:
    mov byte [rdi + rcx], 0     ; Ensure null termination
    
    ; Increment student count
    inc dword [rel _student_count]
    
    ; Display success
    lea rdi, [rel success_msg]
    xor eax, eax
    call _printf
    
    ; Display added student info
    lea rdi, [rel fmt_print]
    mov esi, [rel temp_id]
    lea rdx, [rel temp_name]
    mov ecx, [rel temp_grade]
    xor eax, eax
    call _printf
    
.done:
    pop rbp
    ret

; Get student count - needed by other files
global _get_student_count
_get_student_count:
    mov eax, [rel _student_count]
    ret

; Get student ID at index
global _get_student_id
_get_student_id:
    ; Check if index is valid
    cmp edi, [rel _student_count]
    jge .invalid
    
    ; Calculate address
    mov eax, edi                ; Index
    mov ecx, 4                  ; Size of ID
    mul ecx                     ; eax = index * 4
    lea rcx, [rel _student_ids] ; Base address
    mov eax, [rcx + rax]        ; Get ID
    ret
    
.invalid:
    mov eax, -1
    ret

; Get student name at index
global _get_student_name
_get_student_name:
    ; Check if index is valid
    cmp edi, [rel _student_count]
    jge .invalid
    
    ; Calculate address
    mov eax, edi                 ; Index
    mov ecx, 50                  ; Size of name
    mul ecx                      ; eax = index * 50
    lea rcx, [rel _student_names] ; Base address
    lea rax, [rcx + rax]         ; Get name address
    ret
    
.invalid:
    xor eax, eax
    ret

; Get student grade at index
global _get_student_grade
_get_student_grade:
    ; Check if index is valid
    cmp edi, [rel _student_count]
    jge .invalid
    
    ; Calculate address
    mov eax, edi                  ; Index
    mov ecx, 4                    ; Size of grade
    mul ecx                       ; eax = index * 4
    lea rcx, [rel _student_grades] ; Base address
    mov eax, [rcx + rax]           ; Get grade
    ret
    
.invalid:
    mov eax, -1
    ret

; This function exists for compatibility but just returns index
global _get_student_record
_get_student_record:
    mov eax, edi
    ret