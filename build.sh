#!/bin/bash

# Ensure obj directory exists
mkdir -p obj

# Remove old build files
rm -f obj/*.o
rm -f student_system

# Build student system for Linux
echo "Assembling main.asm..."
nasm -f elf64 src/main.asm -o obj/main.o

echo "Assembling records.asm..."
nasm -f elf64 src/records.asm -o obj/records.o

echo "Assembling file_io.asm..."
nasm -f elf64 src/file_io.asm -o obj/file_io.o

echo "Assembling display.asm..."
nasm -f elf64 src/display.asm -o obj/display.o

echo "Assembling search.asm..."
nasm -f elf64 src/search.asm -o obj/search.o

echo "Assembling calculations.asm..."
nasm -f elf64 src/calculations.asm -o obj/calculations.o

echo "Assembling input.asm..."
nasm -f elf64 src/input.asm -o obj/input.o

if [ $? -ne 0 ]; then
    echo "Assembly failed. Please check errors above."
    exit 1
fi

echo "Linking..."
gcc -o student_system obj/main.o obj/records.o obj/file_io.o obj/display.o obj/search.o obj/calculations.o obj/input.o -no-pie

if [ $? -ne 0 ]; then
    echo "Linking failed. Please check errors above."
    exit 1
fi

echo "Build complete. Run with ./student_system"