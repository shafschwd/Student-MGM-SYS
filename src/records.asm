; records.asm - Student record management for Linux
bits 64

section .data
    ; Constants
    MAX_STUDENTS equ 100    ; Maximum number of students we can store
    
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
    
    ; Student record count
    student_count dd 0
    max_student_id dd 0    ; Tracking highest student ID
    
section .bss
    ; Student record storage
    student_ids resd MAX_STUDENTS    ; Array of student IDs
    student_names resq MAX_STUDENTS  ; Array of pointers to student names
    student_grades resd MAX_STUDENTS ; Array of student grades
    
    ; Temporary variables for input
    temp_id resd 1
    temp_name resb 50
    temp_grade resd 1
    
section .text
    global add_student
    global get_student_count
    global get_student_id
    global get_student_name
    global get_student_grade
    global get_student_record
    global add_student_record, set_max_student_id
    extern printf, scanf, flush_input
    extern malloc, free, strcpy
    extern save_student_to_file     ; From file_io.asm

; Add student record
add_student:
    push rbp
    mov rbp, rsp
    
    ; Check if we've reached maximum students
    mov eax, [student_count]
    cmp eax, MAX_STUDENTS
    jl .continue
    
    ; Maximum reached
    mov rdi, max_students_msg
    xor eax, eax
    call printf
    jmp .done
    
.continue:
    ; Get student ID
    mov rdi, prompt_id
    xor eax, eax
    call printf
    
    mov rdi, fmt_int
    mov rsi, temp_id
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Get student name
    mov rdi, prompt_name
    xor eax, eax
    call printf
    
    mov rdi, fmt_str
    mov rsi, temp_name
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Get grade
    mov rdi, prompt_grade
    mov rsi, 1
    xor eax, eax
    call printf
    
    mov rdi, fmt_int
    mov rsi, temp_grade
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Get current student index
    mov r12d, [student_count]
    
    ; Allocate memory for name
    mov rcx, 0
    mov rsi, temp_name
.count_loop:
    mov al, [rsi + rcx]
    test al, al
    jz .count_done
    inc rcx
    jmp .count_loop
.count_done:
    inc rcx             ; Include null terminator
    
    ; Allocate memory
    mov rdi, rcx
    call malloc
    test rax, rax
    jz .memory_error
    
    ; Store name pointer
    mov [student_names + r12*8], rax
    
    ; Copy name
    mov rdi, rax
    mov rsi, temp_name
    call strcpy
    
    ; Store ID and grade
    mov eax, [temp_id]
    mov [student_ids + r12*4], eax
    
    mov eax, [temp_grade]
    mov [student_grades + r12*4], eax
    
    ; Increment student count
    inc dword [student_count]
    
    ; Display success
    mov rdi, success_msg
    xor eax, eax
    call printf
    
    ; Display added student info
    mov rdi, fmt_print
    mov esi, [temp_id]
    mov rdx, temp_name
    mov ecx, [temp_grade]
    xor eax, eax
    call printf
    
    ; Save student to file
    mov edi, [temp_id]
    mov rsi, temp_name
    mov edx, [temp_grade]
    call save_student_to_file
    
    jmp .done
    
.memory_error:
    ; Memory allocation failed
    mov rdi, max_students_msg  ; Reuse this message
    xor eax, eax
    call printf
    
.done:
    pop rbp
    ret

; Get student count
get_student_count:
    mov eax, [student_count]
    ret

; Get student ID at index
get_student_id:
    ; Check if index is valid
    cmp edi, [student_count]
    jge .invalid
    
    ; Get ID from array
    mov eax, [student_ids + rdi*4]
    ret
    
.invalid:
    mov eax, -1
    ret

; Get student name at index
get_student_name:
    ; Check if index is valid
    cmp edi, [student_count]
    jge .invalid
    
    ; Get name pointer from array
    mov rax, [student_names + rdi*8]
    ret
    
.invalid:
    xor eax, eax  ; Return NULL
    ret

; Get student grade at index
get_student_grade:
    ; Check if index is valid
    cmp edi, [student_count]
    jge .invalid
    
    ; Get grade from array
    mov eax, [student_grades + rdi*4]
    ret
    
.invalid:
    mov eax, -1
    ret

; This function exists for compatibility but just returns index
get_student_record:
    mov eax, edi
    ret

; Add a student record - utility for file loading
; Parameters:
;   rdi = student ID
;   rsi = student name (string)
;   rdx = student grade
add_student_record:
    push rbp
    mov rbp, rsp
    
    ; Save registers
    push r12
    push r13
    push r14
    push r15
    
    ; Save parameters
    mov r12d, edi        ; ID
    mov r13, rsi         ; Name pointer
    mov r14d, edx        ; Grade
    
    ; Check if we have space
    mov eax, [student_count]
    cmp eax, MAX_STUDENTS
    jge .done
    
    ; Get current student index
    mov r15d, eax
    
    ; Count name length
    mov rdi, r13
    mov rcx, 0
.name_length:
    mov al, [rdi + rcx]
    test al, al
    jz .name_length_done
    inc rcx
    jmp .name_length
.name_length_done:
    inc rcx              ; Include null terminator
    
    ; Allocate memory for name
    push r12
    push r13
    push r14
    push r15
    mov rdi, rcx
    call malloc
    pop r15
    pop r14
    pop r13
    pop r12
    
    ; Check if malloc succeeded
    test rax, rax
    jz .done
    
    ; Store the allocated memory address
    mov [student_names + r15*8], rax
    
    ; Copy the name
    push r12
    push r13
    push r14
    push r15
    mov rdi, rax
    mov rsi, r13
    call strcpy
    pop r15
    pop r14
    pop r13
    pop r12
    
    ; Store ID and grade
    mov [student_ids + r15*4], r12d
    mov [student_grades + r15*4], r14d
    
    ; Increment student count
    inc dword [student_count]
    
.done:
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    
    pop rbp
    ret

; Update max student ID 
; Parameters:
;   rdi = new max ID
set_max_student_id:
    ; Only update if new ID is larger
    cmp edi, [max_student_id]
    jle .done
    mov [max_student_id], edi
.done:
    ret