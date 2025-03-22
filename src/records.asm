; records.asm - Student record management for Linux
bits 64

section .data
    ; Constants
    MAX_STUDENTS equ 100    ; Maximum number of students we can store
    NUM_SUBJECTS equ 4      ; Number of subjects per student
    
    ; Prompts
    prompt_id db "Enter student ID: ", 0
    prompt_name db "Enter student name: ", 0
    prompt_grade db "Enter grade for subject %d: ", 0
    success_msg db "Student added successfully!", 10, 0
    max_students_msg db "Maximum number of students reached!", 10, 0
    subject_names db "Math", 0, "Science", 0, "English", 0, "History", 0
    
    ; Delete student prompts
    delete_prompt db "Enter student ID to delete: ", 0
    delete_success db "Student with ID %d deleted successfully!", 10, 0
    delete_not_found db "Student with ID %d not found!", 10, 0
    
    ; Edit grade prompts
    edit_id_prompt db "Enter student ID to edit: ", 0
    edit_subject_prompt db "Enter subject number (1-4): ", 0
    edit_grade_prompt db "Enter new grade: ", 0
    edit_success db "Grade updated successfully!", 10, 0
    edit_invalid_subject db "Invalid subject number. Must be 1-4.", 10, 0
    
    ; Formats
    fmt_int db "%d", 0
    fmt_str db "%s", 0
    fmt_print db "Added student - ID: %d, Name: %s, Grades: [%d, %d, %d, %d]", 10, 0
    
    ; Student record count
    student_count dd 0
    max_student_id dd 0    ; Tracking highest student ID
    
section .bss
    ; Student record storage
    student_ids resd MAX_STUDENTS           ; Array of student IDs
    student_names resq MAX_STUDENTS         ; Array of pointers to student names
    student_grades resd MAX_STUDENTS*NUM_SUBJECTS ; Array of student grades (4 per student)
    
    ; Temporary variables for input
    temp_id resd 1
    temp_name resb 50
    temp_grades resd NUM_SUBJECTS           ; Temporary array for grades
    
section .text
    global add_student
    global get_student_count
    global get_student_id
    global get_student_name
    global get_student_grade
    global get_student_grades
    global calculate_student_avg
    global get_student_record
    global add_student_record, set_max_student_id
    global delete_student, edit_student_grade
    global get_student_by_index  
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
    
    ; Get grades for each subject
    xor r12d, r12d        ; Subject counter

.grade_loop:
    ; Check if we've gotten all subjects
    cmp r12d, NUM_SUBJECTS
    jge .grades_done
    
    ; Prompt for grade
    mov rdi, prompt_grade
    lea rsi, [r12d+1]     ; 1-based subject number for display
    xor eax, eax
    call printf
    
    ; Get grade
    mov rdi, fmt_int
    lea rsi, [temp_grades + r12*4]  ; Store in temp_grades array
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Move to next subject
    inc r12d
    jmp .grade_loop
    
.grades_done:
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
    
    ; Store ID
    mov eax, [temp_id]
    mov [student_ids + r12*4], eax
    
    ; Store all grades
    xor ecx, ecx        ; Loop counter for grades

.store_grades:
    cmp ecx, NUM_SUBJECTS
    jge .grades_stored
    
    ; Calculate base offset for this student's grades
    mov r13d, r12d
    imul r13d, NUM_SUBJECTS   ; student_index * NUM_SUBJECTS
    add r13d, ecx             ; + subject_index
    
    ; Store grade
    mov eax, [temp_grades + ecx*4]
    mov [student_grades + r13*4], eax
    
    inc ecx
    jmp .store_grades
    
.grades_stored:
    ; Increment student count
    inc dword [student_count]
    
    ; Display success message only
    mov rdi, success_msg
    xor eax, eax
    call printf
    
    ; Save student to file
    mov edi, [temp_id]
    mov rsi, temp_name
    lea rdx, [temp_grades]
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

; Delete a student by ID
; Returns: eax = 1 if successful, 0 if not found
delete_student:
    push rbp
    mov rbp, rsp
    sub rsp, 16          ; Space for local variables
    
    ; Prompt for student ID to delete
    lea rdi, [rel delete_prompt]
    xor eax, eax
    call printf
    
    ; Read ID
    lea rdi, [rel fmt_int]
    lea rsi, [rbp-4]     ; Store ID in local variable
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Find student with this ID
    mov r12d, [student_count]  ; Get student count
    xor r13d, r13d             ; Initialize index counter
    
.search_loop:
    ; Check if we've checked all students
    cmp r13d, r12d
    jge .not_found
    
    ; Get student ID at current index
    mov edi, r13d
    call get_student_id
    
    ; Compare with search ID
    cmp eax, [rbp-4]
    je .found
    
    ; Try next student
    inc r13d
    jmp .search_loop
    
.found:
    ; Save the index of the student to delete
    mov [rbp-8], r13d
    
    ; Free the memory used by the student name
    mov rdi, [student_names + r13*8]
    call free
    
    ; If this is the last student, just decrement count
    mov eax, [student_count]
    dec eax
    cmp r13d, eax
    je .last_student
    
    ; Otherwise, shift all subsequent students down
    mov r14d, r13d        ; Start at found index
    
.shift_loop:
    ; Check if we've moved all students
    mov eax, [student_count]
    dec eax
    cmp r14d, eax
    jge .done_shifting
    
    ; Shift student ID
    mov eax, [student_ids + r14*4 + 4]
    mov [student_ids + r14*4], eax
    
    ; Shift student name pointer
    mov rax, [student_names + r14*8 + 8]
    mov [student_names + r14*8], rax
    
    ; Shift student grades (4 per student)
    mov r15d, r14d
    imul r15d, 4         ; r15d = index * 4 (subjects per student)
    
    ; Copy all 4 grades
    mov eax, [student_grades + r15*4 + 4]
    mov [student_grades + r15*4], eax
    mov eax, [student_grades + r15*4 + 8]
    mov [student_grades + r15*4 + 4], eax
    mov eax, [student_grades + r15*4 + 12]
    mov [student_grades + r15*4 + 8], eax
    mov eax, [student_grades + r15*4 + 16]
    mov [student_grades + r15*4 + 12], eax
    
    ; Move to next student
    inc r14d
    jmp .shift_loop
    
.done_shifting:
.last_student:
    ; Decrement student count
    dec dword [student_count]
    
    ; Display success message
    lea rdi, [rel delete_success]
    mov esi, [rbp-4]     ; Deleted student ID
    xor eax, eax
    call printf
    
    mov eax, 1           ; Return success
    add rsp, 16
    pop rbp
    ret
    
.not_found:
    ; Display not found message
    lea rdi, [rel delete_not_found]
    mov esi, [rbp-4]     ; Student ID
    xor eax, eax
    call printf
    
    xor eax, eax         ; Return failure
    add rsp, 16
    pop rbp
    ret

; Edit a student's grade
; Returns: eax = 1 if successful, 0 if student not found
edit_student_grade:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    ; Prompt for student ID
    lea rdi, [rel edit_id_prompt]
    xor eax, eax
    call printf
    
    ; Read ID
    lea rdi, [rel fmt_int]
    lea rsi, [rbp-4]     ; Store ID in local variable
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Find student with this ID
    mov r12d, [student_count]  ; Get student count
    xor r13d, r13d             ; Initialize index counter
    
.search_loop:
    ; Check if we've checked all students
    cmp r13d, r12d
    jge .not_found
    
    ; Get student ID at current index
    mov edi, r13d
    call get_student_id
    
    ; Compare with search ID
    cmp eax, [rbp-4]
    je .found
    
    ; Try next student
    inc r13d
    jmp .search_loop
    
.found:
    ; We found the student, now prompt for subject
    lea rdi, [rel edit_subject_prompt]
    xor eax, eax
    call printf
    
    ; Read subject number (1-4)
    lea rdi, [rel fmt_int]
    lea rsi, [rbp-8]     ; Store subject in local variable
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Validate subject number (1-4)
    mov eax, [rbp-8]
    cmp eax, 1
    jl .invalid_subject
    cmp eax, 4
    jg .invalid_subject
    
    ; Convert to 0-based subject index
    dec eax
    mov [rbp-8], eax
    
    ; Prompt for new grade
    lea rdi, [rel edit_grade_prompt]
    xor eax, eax
    call printf
    
    ; Read new grade
    lea rdi, [rel fmt_int]
    lea rsi, [rbp-12]    ; Store new grade in local variable
    xor eax, eax
    call scanf
    
    call flush_input
    
    ; Update the grade in memory
    mov edi, r13d        ; Student index
    mov esi, [rbp-8]     ; Subject index (0-3)
    mov edx, [rbp-12]    ; New grade
    call set_student_grade
    
    ; Show success message
    lea rdi, [rel edit_success]
    xor eax, eax
    call printf
    
    mov eax, 1           ; Return success
    add rsp, 16
    pop rbp
    ret
    
.invalid_subject:
    ; Display invalid subject message
    lea rdi, [rel edit_invalid_subject]
    xor eax, eax
    call printf
    
    xor eax, eax         ; Return failure
    add rsp, 16
    pop rbp
    ret
    
.not_found:
    ; Display not found message
    lea rdi, [rel delete_not_found]  ; Reuse the delete error message
    mov esi, [rbp-4]     ; Student ID
    xor eax, eax
    call printf
    
    xor eax, eax         ; Return failure
    add rsp, 16
    pop rbp
    ret

; Set a student's grade for a specific subject
; Parameters:
;   rdi = student index
;   rsi = subject index (0-3)
;   rdx = new grade
set_student_grade:
    ; Calculate offset for grade: student_index * NUM_SUBJECTS + subject_index
    mov eax, edi
    imul eax, NUM_SUBJECTS
    add eax, esi
    
    ; Update the grade
    mov [student_grades + rax*4], edx
    ret

; Common functionality for getting student information

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

; Get a specific grade for student (grade for one subject)
; Parameters:
;   rdi = student index
;   rsi = subject index (0-3)
; Returns:
;   eax = grade or -1 if invalid
get_student_grade:
    ; Check if indices are valid
    cmp edi, [student_count]
    jge .invalid
    
    cmp esi, NUM_SUBJECTS
    jge .invalid
    
    ; Calculate offset for grade: student_index * NUM_SUBJECTS + subject_index
    mov eax, edi
    imul eax, NUM_SUBJECTS
    add eax, esi
    
    ; Get grade from array
    mov eax, [student_grades + rax*4]
    ret
    
.invalid:
    mov eax, -1
    ret

; Get pointer to all grades for a student
; Parameters:
;   rdi = student index
; Returns:
;   rax = pointer to grades array or NULL if invalid
get_student_grades:
    ; Check if index is valid
    cmp edi, [student_count]
    jge .invalid
    
    ; Calculate base offset for this student's grades
    mov eax, edi
    imul eax, NUM_SUBJECTS
    
    ; Return pointer to first grade
    lea rax, [student_grades + rax*4]
    ret
    
.invalid:
    xor eax, eax  ; Return NULL
    ret

; Calculate average grade for a student on a 4.0 GPA scale
; Parameters:
;   rdi = student index
; Returns:
;   eax = GPA on 4.0 scale (multiplied by 10 for one decimal place)
calculate_student_avg:
    push rbp
    mov rbp, rsp
    
    ; Check if index is valid
    cmp edi, [student_count]
    jge .invalid
    
    ; Save student index
    mov r12d, edi
    
    ; Initialize sum
    xor r13d, r13d
    
    ; Loop through all subjects
    xor r14d, r14d

.sum_loop:
    cmp r14d, NUM_SUBJECTS
    jge .sum_done
    
    ; Get grade for this subject
    mov edi, r12d
    mov esi, r14d
    call get_student_grade
    
    ; Add to sum
    add r13d, eax
    
    ; Next subject
    inc r14d
    jmp .sum_loop
    
.sum_done:
    ; Calculate average (sum / NUM_SUBJECTS)
    mov eax, r13d
    cdq                  ; Sign extend eax into edx:eax
    mov ecx, NUM_SUBJECTS
    idiv ecx             ; eax = (edx:eax) / ecx
    
    ; Convert to 4.0 scale (with one decimal place)
    ; GPA = (grade / 100) * 4.0
    ; To keep one decimal place, we multiply by 40 instead of 4
    imul eax, 40         ; eax = avg * 40
    mov ecx, 100
    cdq                  ; Sign extend eax into edx:eax
    idiv ecx             ; eax = (edx:eax) / 100
    
    ; Cap at 40 (4.0)
    cmp eax, 40
    jle .done
    mov eax, 40          ; Maximum is 4.0
    
.done:
    pop rbp
    ret
    
.invalid:
    mov eax, -1
    pop rbp
    ret

; This function exists for compatibility but just returns index
get_student_record:
    mov eax, edi
    ret

; Add a student record with multiple grades - utility for file loading
; Parameters:
;   rdi = student ID
;   rsi = student name (string)
;   rdx = pointer to grades array (4 integers)
add_student_record:
    push rbp
    mov rbp, rsp
    
    ; Save parameters to the stack to simplify our work
    push rdi  ; student ID
    push rsi  ; student name pointer
    push rdx  ; grades array pointer
    
    ; Check if we have space
    mov eax, [student_count]
    cmp eax, MAX_STUDENTS
    jge .done
    
    ; Get current student index
    mov r15d, eax
    
    ; Allocate and store the name
    mov rdi, [rbp-16]    ; Get the name pointer back
    mov rcx, 0
    
    ; Count name length
    mov rsi, rdi
.name_length:
    mov al, [rsi + rcx]
    test al, al
    jz .name_length_done
    inc rcx
    jmp .name_length
.name_length_done:
    inc rcx              ; Include null terminator
    
    ; Save the name pointer
    push rdi
    
    ; Allocate memory for name
    mov rdi, rcx
    call malloc
    
    ; Save the allocated memory address
    mov rdi, rax
    pop rsi              ; Get the name pointer back
    
    ; Check if malloc succeeded
    test rdi, rdi
    jz .done
    
    ; Store name pointer
    mov [student_names + r15*8], rdi
    
    ; Copy the name
    call strcpy
    
    ; Store ID
    mov eax, [rbp-8]     ; Get the ID from the stack
    mov [student_ids + r15*4], eax
    
    ; Get the grades array pointer
    mov rdx, [rbp-24]
    
    ; Store the grades individually (safest approach)
    ; Grades in file are: Math, Science, English, History
    ; But they're displayed as:
    ; Math (stored at index 0)
    ; Science (stored at index 1)
    ; English (stored at index 2)
    ; History (stored at index 3)
    
    ; Math (1st grade in file -> index 0)
    mov eax, [rdx]
    mov r9d, r15d
    imul r9d, NUM_SUBJECTS
    mov [student_grades + r9*4], eax
    
    ; Science (2nd grade in file -> index 1)
    mov eax, [rdx+4]
    inc r9d
    mov [student_grades + r9*4], eax
    
    ; English (3rd grade in file -> index 2)
    mov eax, [rdx+8]
    inc r9d
    mov [student_grades + r9*4], eax
    
    ; History (4th grade in file -> index 3)
    mov eax, [rdx+12]
    inc r9d
    mov [student_grades + r9*4], eax
    
    ; Increment student count
    inc dword [student_count]
    
.done:
    ; Clean up the stack
    add rsp, 24  ; 3 pushes * 8 bytes
    
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

; Function to get student by index
; Parameters:
;   rdi = index of student to retrieve (0-based)
; Returns:
;   rax = pointer to student record or 0 if index out of bounds
get_student_by_index:
    push rbp
    mov rbp, rsp
    
    ; Check if index is valid
    cmp edi, [student_count]
    jge .invalid_index
    
    ; Our student records are distributed across multiple arrays
    ; We need to create a struct with all the info and return it
    
    ; We'll define a temporary storage structure for our student record
    ; This will be allocated on the stack
    ; Format: ID (4 bytes) | Name (50 bytes) | Grades (16 bytes)
    sub rsp, 80  ; Allocate space for our struct (70 bytes + padding)
    
    ; Store the ID
    mov eax, [student_ids + rdi*4]
    mov [rsp], eax
    
    ; Copy the name
    mov rsi, [student_names + rdi*8]  ; Source name
    lea rdi, [rsp + 4]                ; Destination (after the ID)
    
    ; Simple byte-by-byte copy of the name
    mov rcx, 0
.copy_loop:
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    inc rcx
    test al, al
    jnz .copy_loop
    
    ; Store grades
    mov eax, edi
    imul eax, NUM_SUBJECTS  ; eax = student_index * NUM_SUBJECTS
    lea rdx, [student_grades + rax*4]  ; Source grades
    lea rdi, [rsp + 54]                ; Destination (after ID and name)
    
    ; Copy grades
    mov eax, [rdx]
    mov [rdi], eax
    mov eax, [rdx + 4]
    mov [rdi + 4], eax
    mov eax, [rdx + 8]
    mov [rdi + 8], eax
    mov eax, [rdx + 12]
    mov [rdi + 12], eax
    
    ; Return pointer to the constructed record
    mov rax, rsp
    
    ; We'll leave the cleanup to the caller as the struct is on the stack
    pop rbp
    ret
    
.invalid_index:
    xor eax, eax  ; Return NULL if index is out of bounds
    pop rbp
    ret