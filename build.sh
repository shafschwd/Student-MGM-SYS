#!/bin/bash
# Build student system
nasm -f macho64 src/main.asm -o main.o
nasm -f macho64 src/records.asm -o records.o

if [ $? -ne 0 ]; then
    echo "Assembly failed. Please check errors above."
    exit 1
fi

gcc -o student_system main.o records.o

if [ $? -ne 0 ]; then
    echo "Linking failed. Please check errors above."
    exit 1
fi

echo "Build complete. Run with ./student_system"