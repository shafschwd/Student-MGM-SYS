; records.asm - Multiple student record management with file persistence
section .data
    ; Constants
    MAX_STUDENTS equ 10              ; Maximum number of students
    RECORD_SIZE equ 60               ; Size of each student record
    ID_OFFSET equ 0                  ; Offset of ID field in record
    NAME_OFFSET equ 4                ; Offset of name field in record
    NAME_SIZE equ 50                 ; Maximum name length
    GRADE_OFFSET equ 54              ; Offset of grade field in record
    
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
    
    ; File operations
    file_path db "../student_records.txt", 0  ; File to store student data
    file_mode_w db "w", 0                 ; Write mode
    file_mode_r db "r", 0                 ; Read mode
    file_write_fmt db "%d,%s,%d", 10, 0   ; Format for writing to file
    file_read_fmt db "%d,%[^,],%d", 0     ; Format for reading from file
    file_save_msg db "Student records saved to file.", 10, 0
    file_load_msg db "Student records loaded from file.", 10, 0
    
    ; Counter
    global student_count
    student_count dd 0
    
section .bss
    ; Student records array
    global student_records
    student_records resb MAX_STUDENTS * RECORD_SIZE
    
    ; Temp variables for input
    temp_id resd 1
    temp_name resb NAME_SIZE
    temp_grade resd 1
    
section .text
    global _add_student
    global _get_student_record
    global _get_student_count
    global _get_max_students
    global _save_records
    global _load_records
    extern _printf, _scanf, _flush_input, _strcmp
    extern _fopen, _fclose, _fprintf, _fscanf, _feof
    
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
    call _printf
    jmp .done
    
.continue:
    ; Get student ID
    lea rdi, [rel prompt_id]
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel temp_id]
    call _scanf
    
    call _flush_input
    
    ; Get student name
    lea rdi, [rel prompt_name]
    call _printf
    
    lea rdi, [rel fmt_str]
    lea rsi, [rel temp_name]
    call _scanf
    
    call _flush_input
    
    ; Get grade
    lea rdi, [rel prompt_grade]
    mov rsi, 1
    call _printf
    
    lea rdi, [rel fmt_int]
    lea rsi, [rel temp_grade]
    call _scanf
    
    call _flush_input
    
    ; Calculate record address
    mov eax, [rel student_count]    ; Get current number of students
    mov r9d, RECORD_SIZE            ; Size of each record
    mul r9d                         ; eax = student_count * RECORD_SIZE
    lea rdi, [rel student_records]  ; Base address of student records
    add rdi, rax                    ; rdi = address of new record
    
    ; Store ID
    mov eax, [rel temp_id]
    mov [rdi + ID_OFFSET], eax
    
    ; Store name
    mov rcx, 0                      ; Initialize counter
.copy_name:
    cmp rcx, NAME_SIZE-1            ; Check if we've reached max name length
    jge .name_done
    
    mov al, [rel temp_name + rcx]   ; Get character from temp_name
    mov [rdi + NAME_OFFSET + rcx], al ; Store in record
    
    test al, al                     ; Check if null terminator
    jz .name_done
    
    inc rcx
    jmp .copy_name
    
.name_done:
    ; Ensure null termination
    mov byte [rdi + NAME_OFFSET + rcx], 0
    
    ; Store grade
    mov eax, [rel temp_grade]
    mov [rdi + GRADE_OFFSET], eax
    
    ; Increment student count
    inc dword [rel student_count]
    
    ; Display success message and student info
    lea rdi, [rel success_msg]
    call _printf
    
    lea rdi, [rel fmt_print]
    mov esi, [rel temp_id]
    lea rdx, [rel temp_name]
    mov ecx, [rel temp_grade]
    call _printf
    
    ; Save records to file after adding
    call _save_records
    
.done:
    pop rbp
    ret

; Save student records to file
_save_records:
    push rbp
    mov rbp, rsp
    sub rsp, 16                    ; Allocate space for local variables
    
    ; Open file for writing
    lea rdi, [rel file_path]
    lea rsi, [rel file_mode_w]
    call _fopen
    
    ; Check if file opened successfully
    test rax, rax
    jz .done                       ; Exit if file couldn't be opened
    
    ; Store file pointer
    mov [rsp], rax
    
    ; Loop through all students and write to file
    mov ebx, 0                     ; Initialize counter
.write_loop:
    cmp ebx, [rel student_count]   ; Check if we've processed all students
    jge .close_file
    
    ; Get student record
    mov eax, ebx
    mov r9d, RECORD_SIZE
    mul r9d                        ; eax = index * RECORD_SIZE
    lea r10, [rel student_records] ; Base address of student records
    add r10, rax                   ; r10 = address of current record
    
    ; Write record to file
    mov rdi, [rsp]                 ; File pointer
    lea rsi, [rel file_write_fmt]
    mov edx, [r10 + ID_OFFSET]     ; ID
    lea rcx, [r10 + NAME_OFFSET]   ; Name
    mov r8d, [r10 + GRADE_OFFSET]  ; Grade
    call _fprintf
    
    inc ebx                        ; Increment counter
    jmp .write_loop
    
.close_file:
    ; Close file
    mov rdi, [rsp]
    call _fclose
    
    ; Display success message
    lea rdi, [rel file_save_msg]
    call _printf
    
.done:
    add rsp, 16                    ; Clean up stack
    pop rbp
    ret

; Load student records from file
_load_records:
    push rbp
    mov rbp, rsp
    sub rsp, 32                    ; Allocate space for local variables
    
    ; Reset student count
    mov dword [rel student_count], 0
    
    ; Open file for reading
    lea rdi, [rel file_path]
    lea rsi, [rel file_mode_r]
    call _fopen
    
    ; Check if file opened successfully
    test rax, rax
    jz .done                       ; Exit if file couldn't be opened
    
    ; Store file pointer
    mov [rsp], rax
    
.read_loop:
    ; Check if we've reached EOF
    mov rdi, [rsp]
    call _feof
    test eax, eax
    jnz .close_file
    
    ; Check if we've reached maximum students
    mov eax, [rel student_count]
    cmp eax, MAX_STUDENTS
    jge .close_file
    
    ; Calculate record address
    mov eax, [rel student_count]
    mov r9d, RECORD_SIZE
    mul r9d                        ; eax = student_count * RECORD_SIZE
    lea r10, [rel student_records] ; Base address of student records
    add r10, rax                   ; r10 = address of current record
    
    ; Read record from file
    mov rdi, [rsp]                 ; File pointer
    lea rsi, [rel file_read_fmt]
    lea rdx, [r10 + ID_OFFSET]     ; ID
    lea rcx, [r10 + NAME_OFFSET]   ; Name
    lea r8, [r10 + GRADE_OFFSET]   ; Grade
    call _fscanf
    
    ; Check if read was successful
    cmp eax, 3                     ; Should have read 3 items
    jne .read_loop
    
    ; Increment student count
    inc dword [rel student_count]
    jmp .read_loop
    
.close_file:
    ; Close file
    mov rdi, [rsp]
    call _fclose
    
    ; Display success message
    lea rdi, [rel file_load_msg]
    call _printf
    
.done:
    add rsp, 32                    ; Clean up stack
    pop rbp
    ret

; Get student record by index
; Parameters: rdi = index
; Returns: rax = pointer to student record or 0 if invalid index
_get_student_record:
    ; Check if index is valid
    cmp edi, [rel student_count]
    jge .invalid_index
    
    ; Calculate record address
    mov eax, edi
    mov r9d, RECORD_SIZE
    mul r9d                      ; eax = index * RECORD_SIZE
    lea rax, [rel student_records + rax] ; rax = address of record
    ret
    
.invalid_index:
    xor eax, eax                 ; Return 0 for invalid index
    ret

; Get student count
; Returns: eax = number of students
_get_student_count:
    mov eax, [rel student_count]
    ret

; Get maximum students
; Returns: eax = maximum number of students
_get_max_students:
    mov eax, MAX_STUDENTS
    ret