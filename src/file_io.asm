; file_io.asm - File operations for student records
bits 64

section .data
    ; File paths
    records_file db "student_records.txt", 0
    
    ; File modes
    read_mode db "r", 0
    append_mode db "a", 0
    write_mode db "w", 0
    
    ; Format strings  
    record_fmt db "%d,%s,%d,%d,%d,%d", 10, 0  ; Changed to separate newline character
    scan_fmt db "%d,%[^,],%d,%d,%d,%d", 0
    
    ; Messages
    loading_msg db "Loading students from file...", 10, 0
    loaded_count db "Loaded %d students.", 10, 0
    no_file_msg db "No previous records file found. Using default data.", 10, 0
    saving_msg db "Saving student to file...", 10, 0
    saved_msg db "Student saved to file.", 10, 0
    saving_all_msg db "Saving all students to file...", 10, 0
    saved_all_msg db "All students saved to file.", 10, 0
    err_open db "Error: Could not open file.", 10, 0
    
    ; Hard-coded student names and grades as fallback
    student1_name db "John Doe", 0
    student2_name db "Jane Smith", 0
    student3_name db "Bob Johnson", 0
    
    student1_grades dd 85, 78, 92, 88
    student2_grades dd 92, 95, 89, 94
    student3_grades dd 78, 82, 75, 80
    
section .bss
    temp_id resd 1
    temp_name resb 50
    temp_grades resd 4     ; Array for 4 grades
    
section .text
    global save_student_to_file, load_students_from_file, save_all_students_to_file
    extern printf, fprintf, fscanf, fopen, fclose, feof, fgetc
    extern add_student_record, get_student_count, get_student_by_index
    extern get_student_id, get_student_name, get_student_grades

; Save student with multiple grades to file
; Parameters:
;   rdi = student ID
;   rsi = student name string
;   rdx = pointer to array of 4 grades
save_student_to_file:
    push rbp
    mov rbp, rsp
    sub rsp, 16          ; Space for file handle
    
    ; Save parameters
    mov [temp_id], edi
    mov rcx, rsi     ; Name source
    mov r8, rdx      ; Save grades pointer in r8 to avoid confusion
    lea rdx, [temp_name]
    
    ; Copy name (simple loop)
    xor rax, rax
.copy_loop:
    mov bl, [rcx + rax]
    mov [rdx + rax], bl
    test bl, bl
    jz .copy_done
    inc rax
    cmp rax, 49
    jl .copy_loop
    mov BYTE [rdx + rax], 0  ; Ensure null-termination
    
.copy_done:
    ; Copy grades from the array
    mov eax, [r8]
    mov [temp_grades], eax
    mov eax, [r8+4]
    mov [temp_grades+4], eax
    mov eax, [r8+8]
    mov [temp_grades+8], eax
    mov eax, [r8+12]
    mov [temp_grades+12], eax
    
    ; Print message
    lea rdi, [saving_msg]
    xor eax, eax
    call printf
    
    ; Open file for appending
    lea rdi, [records_file]
    lea rsi, [append_mode]
    call fopen
    mov [rbp-8], rax     ; Save file handle
    
    ; Check if file was opened successfully
    test rax, rax
    jz .error_opening
    
    ; Write student record to file
    mov rdi, [rbp-8]     ; File handle
    lea rsi, [record_fmt]
    mov edx, [temp_id]
    lea rcx, [temp_name]
    mov r8d, [temp_grades]
    mov r9d, [temp_grades+4]
    ; Push the remaining grades on the stack
    mov rax, [temp_grades+12]
    push rax
    mov rax, [temp_grades+8]
    push rax
    call fprintf
    add rsp, 16          ; Clean up stack
    
    ; Close the file
    mov rdi, [rbp-8]
    call fclose
    
    ; Display success message
    lea rdi, [saved_msg]
    xor eax, eax
    call printf
    
    xor eax, eax         ; Return success
    add rsp, 16
    pop rbp
    ret
    
.error_opening:
    ; Display error message
    lea rdi, [err_open]
    xor eax, eax
    call printf
    
    mov eax, 1           ; Return error
    add rsp, 16
    pop rbp
    ret

; Save all students to file
; This should be called when the program exits
save_all_students_to_file:
    push rbp
    mov rbp, rsp
    sub rsp, 64                  ; Space for local variables and alignment
    
    ; Print message
    lea rdi, [saving_all_msg]
    xor eax, eax
    call printf
    
    ; Open file for writing (not appending - to overwrite)
    lea rdi, [records_file]
    lea rsi, [write_mode]        ; Use write mode to overwrite the file
    call fopen
    mov [rbp-8], rax             ; Save file handle at [rbp-8]
    
    ; Check if file was opened successfully
    test rax, rax
    jz .error_save
    
    ; Get student count
    call get_student_count
    mov [rbp-12], eax            ; Save student count at [rbp-12]
    
    ; Initialize counter for loop
    xor r12d, r12d               ; r12d = loop counter (i)
    
.save_loop:
    ; Check if we've processed all students
    cmp r12d, [rbp-12]
    jge .save_done
    
    ; Get student info
    mov edi, r12d
    call get_student_id
    mov [rbp-16], eax            ; Store student ID
    
    mov edi, r12d
    call get_student_name
    mov [rbp-24], rax            ; Store student name pointer
    
    ; Check if name pointer is valid
    test rax, rax
    jz .next_student
    
    mov edi, r12d
    call get_student_grades
    mov [rbp-32], rax            ; Store grades pointer
    
    ; Check if grades pointer is valid
    test rax, rax
    jz .next_student
    
    ; Write to file - use fprintf directly with a different format string
    mov rdi, [rbp-8]             ; File handle
    lea rsi, [record_fmt]        ; Format string
    mov edx, [rbp-16]            ; Student ID
    mov rcx, [rbp-24]            ; Student name pointer
    
    mov r10, [rbp-32]            ; Grades pointer
    mov r8d, [r10]               ; First grade
    mov r9d, [r10+4]             ; Second grade
    
    ; Push the additional grades
    mov eax, [r10+12]            ; Fourth grade
    push rax
    mov eax, [r10+8]             ; Third grade
    push rax
    
    call fprintf
    add rsp, 16                  ; Clean up stack
    
.next_student:
    inc r12d
    jmp .save_loop
    
.save_done:
    ; Close the file
    mov rdi, [rbp-8]
    call fclose
    
    ; Display success message
    lea rdi, [saved_all_msg]
    xor eax, eax
    call printf
    
    mov eax, 0                   ; Return success
    add rsp, 64
    pop rbp
    ret
    
.error_save:
    ; Display error message
    lea rdi, [err_open]
    xor eax, eax
    call printf
    
    mov eax, 1                   ; Return error
    add rsp, 64
    pop rbp
    ret

; Load student records from file
; Returns: Number of students loaded
load_students_from_file:
    push rbp
    mov rbp, rsp
    sub rsp, 32                  ; Space for file handle and local vars
    
    ; Print loading message
    lea rdi, [loading_msg]
    xor eax, eax
    call printf
    
    ; Open file for reading
    lea rdi, [records_file]
    lea rsi, [read_mode]
    call fopen
    mov [rbp-8], rax             ; Save file handle
    
    ; Check if file was opened successfully
    test rax, rax
    jz .use_defaults
    
    ; Initialize student count
    xor r12d, r12d               ; Number of students loaded
    
.load_loop:
    ; Check for end of file
    mov rdi, [rbp-8]
    call feof
    test eax, eax
    jnz .done_loading
    
    ; Allocate space for student info on the stack
    sub rsp, 80                  ; Space for ID, name, grades
    
    ; Clear the buffer
    mov dword [rsp], 0           ; Clear ID
    mov byte [rsp+4], 0          ; Clear first byte of name
    mov dword [rsp+54], 0        ; Clear first grade (Math)
    mov dword [rsp+58], 0        ; Clear second grade (Science)
    mov dword [rsp+62], 0        ; Clear third grade (English)
    mov dword [rsp+66], 0        ; Clear fourth grade (History)
    
    ; Read student record from file
    mov rdi, [rbp-8]             ; File handle
    lea rsi, [scan_fmt]          ; Format string
    lea rdx, [rsp]               ; ID
    lea rcx, [rsp+4]             ; Name
    lea r8, [rsp+54]             ; Math grade
    lea r9, [rsp+58]             ; Science grade
    
    ; Push additional parameters for fscanf (English and History grades)
    lea rax, [rsp+66]            ; Address for History grade
    push rax
    lea rax, [rsp+62+8]          ; Address for English grade (adjusted for stack push)
    push rax
    
    call fscanf
    add rsp, 16                  ; Clean up stack
    
    ; Check if read was successful
    cmp eax, 6                   ; We expect 6 items (ID, name, 4 grades)
    jl .skip_record
    
    ; Add student to memory
    mov edi, [rsp]               ; ID
    lea rsi, [rsp+4]             ; Name
    lea rdx, [rsp+54]            ; Grades array
    call add_student_record
    
    ; Increment count of loaded students
    inc r12d
    
.skip_record:
    add rsp, 80                  ; Clean up stack space for student
    jmp .load_loop
    
.done_loading:
    ; Close the file
    mov rdi, [rbp-8]
    call fclose
    
    ; Display count of loaded students
    lea rdi, [loaded_count]
    mov esi, r12d
    xor eax, eax
    call printf
    
    ; Return number of students loaded
    mov eax, r12d
    add rsp, 32
    pop rbp
    ret
    
.use_defaults:
    ; Display message about using defaults
    lea rdi, [no_file_msg]
    xor eax, eax
    call printf
    
    ; Add three sample records with corrected grade order
    ; Student 1
    mov edi, 101
    lea rsi, [student1_name]
    lea rdx, [student1_grades]
    call add_student_record
    
    ; Student 2
    mov edi, 102
    lea rsi, [student2_name]
    lea rdx, [student2_grades]
    call add_student_record
    
    ; Student 3
    mov edi, 103
    lea rsi, [student3_name]
    lea rdx, [student3_grades]
    call add_student_record
    
    ; Print loaded count
    lea rdi, [loaded_count]
    mov esi, 3                   ; 3 students loaded
    xor eax, eax
    call printf
    
    mov eax, 3                   ; Return 3 students
    add rsp, 32
    pop rbp
    ret