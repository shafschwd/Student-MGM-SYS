#!/bin/bash

echo "Starting the build process..."
./build.sh

if [ $? -ne 0 ]; then
    echo "Build failed. Please check the error messages above."
    exit 1
fi

echo "Build successful! Running the student management system..."

# Run with explicit debugging output
echo "Running student management system..."
./student_system