#!/bin/bash

echo "Starting the build process..."
# Run the build script
chmod +x ./build.sh
./build.sh

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Running the student management system..."
    # Run the student system program
    ./student_system
else
    echo "Build failed. Please check the error messages above."
    exit 1
fi