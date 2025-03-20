#!/bin/bash

# Ensure obj directory exists
mkdir -p obj

# Remove old build files
rm -f obj/*.o
rm -f student_system

# Build student system with the most basic, macOS-compatible version
nasm -f macho64 src/main.asm -o obj/main.o
nasm -f macho64 src/records.asm -o obj/records.o
nasm -f macho64 src/display.asm -o obj/display.o
nasm -f macho64 src/calculations.asm -o obj/calculations.o
nasm -f macho64 src/search.asm -o obj/search.o

if [ $? -ne 0 ]; then
    echo "Assembly failed. Please check errors above."
    exit 1
fi

gcc -o student_system obj/main.o obj/records.o obj/display.o obj/calculations.o obj/search.o

if [ $? -ne 0 ]; then
    echo "Linking failed. Please check errors above."
    exit 1
fi

echo "Build complete. Run with ./student_system"