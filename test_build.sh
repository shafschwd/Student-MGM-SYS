#!/bin/bash
nasm -f macho64 src/main.asm -o main.o
gcc -o student_system main.o
echo "Test build complete. Run with ./student_system"