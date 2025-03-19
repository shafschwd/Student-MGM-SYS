#!/bin/bash
# Build script for Student Record Management System

# Create obj directory if it doesn't exist
mkdir -p obj

# Assemble each source file
nasm -f macho64 src/main.asm -o obj/main.o
nasm -f macho64 src/input.asm -o obj/input.o
nasm -f macho64 src/display.asm -o obj/display.o
nasm -f macho64 src/calculations.asm -o obj/calculations.o
nasm -f macho64 src/records.asm -o obj/records.o

# Check if assembly was successful
if [ $? -ne 0 ]; then
    echo "Assembly failed. Please check the errors above."
    exit 1
fi

# Link all object files
gcc -o student_system obj/main.o obj/input.o obj/display.o obj/calculations.o obj/records.o

# Check if linking was successful
if [ $? -ne 0 ]; then
    echo "Linking failed. Please check the errors above."
    exit 1
fi

echo "Build complete. Run with ./student_system"