#!/bin/bash
# Script to compile and run C++ code from Zed editor with execution time and memory usage limits

# @author: Dipanshu Mahato
# @email: d1p@duck.com

# ANSI color codes
RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"
ITALIC="\033[3m"
YELLOW="\033[33m"

# Check if the filename is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No filename provided${RESET}"
    display_help
    exit 1
fi

file="$1"  # The first argument is the C++ file to run  

# Function to display help
display_help() {
    echo "Usage: ./compile_cpp.sh [options] <filename.cpp>"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo
    echo "This script compiles and runs a C++ file, displaying the execution time"
    echo "and memory usage. It sets a maximum execution time of 5 seconds and a"
    echo "maximum memory limit of 512 MB."
    echo
    echo "Examples:"
    echo "  ./compile_cpp.sh path/to/my_cpp_program.cpp"
    echo "  ./compile_cpp.sh --help"
    exit 0
}

# Get the directory and base filename without extension
dir=$(dirname "$file")
base=$(basename "$file" .cpp)  # Change .cpp to match your file extension if different

# Modify time and memory limits here
time_limit=5 # min: 1, max: 100 (in sec)
memory_limit=524288 # min: 100, max: 2097152 (in kBs)
max_file_size=5242880 # 5 MB in bytes

# Delete binaries and its directory if its empty
cleanup() {
    rm "$dir/bin/$base.out"  # Delete the output file after execution
    
    if [ -d "$dir/bin" ] && [ -z "$(ls -A "$dir/bin")" ]; then # Check and delete if bin is empty
        rmdir "$dir/bin"
    fi
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
fi

# Check if the file exists
if [ ! -f "$file" ]; then
    echo -e "${RED}Error: Cannot find '$file': No such file or directory${RESET}"
    exit 1
fi

file_size=$(stat -c%s "$file") # File size in bytes

# Check if the file exceeds the maximum allowed size
if [ "$file_size" -gt "$max_file_size" ]; then
    echo -e "${RED}Error: File size exceeds 5 MB (${file_size} bytes). Exiting.${RESET}"
    
    exit 1
fi

# Create bin directory if it doesn't exist
mkdir -p "$dir/bin"

# Compile the C++ file using g++
g++ -std=c++17 -fsanitize=address -g "$file" -o "$dir/bin/$base.out"

if [ $? -eq 0 ]; then # compilation successful
    export ASAN_OPTIONS=detect_leaks=0  # Disable leak detection for ASan (not freeing memory will not cause an error)
    
    start=$(date +%s%N) # Start time
    
    "$dir/bin/$base.out" & # Run the compiled program 
    pid=$!  # Get the process ID of the last background command
    
    memory=0
    # Monitor the process
    while kill -0 $pid 2>/dev/null; do
        # Get the memory usage of the process
        m=$(cat /proc/$pid/status | grep VmRSS | awk '{print $2}')
        if [ $m -gt $memory ]; then
            memory=$m
        fi
        # echo $memory $m
        
        # Check elapsed time
        elapsed=$(( ($(date +%s%N) - start) / 1000000 ))  # Convert to milliseconds
        if [ $elapsed -ge $((time_limit * 1000)) ]; then
            kill -15 $pid  # Terminate if TLE
            echo ""
            echo -e "${RED}TLE: Time limit exceeded${RESET}"
            
            cleanup  # Clean up
            exit 1
        elif [ $memory -ge $memory_limit ]; then
            kill -15 $pid  # Terminate if MLE
            echo ""
            echo -e "${RED}MLE: Memory limit exceeded${RESET}"
            
            cleanup  # Clean up
            exit 1
        fi
        sleep 0.1  # Sleep for a short time to avoid busy waiting
    done
    
    wait $pid
    
    # Capture the exit status after the process ends
    status=$?
    
    if [ $status -ne 0 ]; then
        echo ""
        echo -e "${RED}RE: Runtime error${RESET}"
        
        cleanup  # Clean up
        exit 1
    fi
    
    end=$(date +%s%N)
    # Calculate real time
    elapsed=$((end - start))
    
    real_time_ms=$((elapsed / 1000000))  # Convert to milliseconds
    real_time_s=$((elapsed / 1000000000))  # Convert to seconds
    
    echo ""
    echo -e "${GREEN}Executed${RESET}"
    echo -e "${YELLOW}Time Taken: ${real_time_s}.${real_time_ms}s${RESET}"
    # TODO: Implement MB conversion
    echo -e "${YELLOW}Memory: ${memory} KB${RESET}"
    
    cleanup  # Delete the output file after execution
    exit 0
else # compilation failed
    echo ""
    echo -e "${RED}Compilation failed.${RESET}"
    exit 1
fi

# TODO: Add support for input redirection and output redirection
