#!/bin/bash

echo "Starting the build process..."

# Create obj directory if it doesn't exist
mkdir -p obj

# Compile assembly files
echo "Assembling main.asm..."
nasm -f elf64 -o obj/main.o src/main.asm

echo "Assembling records.asm..."
nasm -f elf64 -o obj/records.o src/records.asm

echo "Assembling file_io.asm..."
nasm -f elf64 -o obj/file_io.o src/file_io.asm

echo "Assembling display.asm..."
nasm -f elf64 -o obj/display.o src/display.asm

echo "Assembling search.asm..."
nasm -f elf64 -o obj/search.o src/search.asm

echo "Assembling calculations.asm..."
nasm -f elf64 -o obj/calculations.o src/calculations.asm

echo "Assembling input.asm..."
nasm -f elf64 -o obj/input.o src/input.asm

# Assemble debug.asm if it exists and is not empty
if [ -s src/debug.asm ]; then
    echo "Assembling debug.asm..."
    nasm -f elf64 -o obj/debug.o src/debug.asm
fi

# Link object files
echo "Linking..."
if gcc -no-pie -o student_system obj/*.o -lc; then
    echo "Build complete. Run with ./student_system"
    exit 0
else
    echo "Linking failed. Please check errors above."
    exit 1
fi