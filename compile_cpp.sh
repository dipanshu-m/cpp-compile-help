#!/bin/bash
# Script to compile and run C++ code from Zed editor with execution time and memory usage limits

# @author: Dipanshu Mahato
# @email: d1p@duck.com

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

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
fi

RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"
ITALIC="\033[3m"
YELLOW="\033[33m"

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No filename provided${RESET}"
    display_help
    exit 1
fi

file="$1"  # The first argument is the C++ file to run  

if [ ! -f "$file" ]; then
    echo -e "${RED}Error: Cannot find '$file': No such file or directory${RESET}"
    exit 1
fi

# Get the directory and base filename without extension
dir=$(dirname "$file")
base=$(basename "$file" .cpp)  # Change .cpp to match your file extension if different

#modify time and memory limits
time_limit=5 # min: 1, max: 100
memory_limit=524288 #min: 100, max: 2097152

# Create bin directory if it doesn't exist
mkdir -p "$dir/bin"

# Compile the C++ file using g++
g++ -std=c++17 "$file" -o "$dir/bin/$base.out"

# Check if compilation was successful
if [ $? -eq 0 ]; then
    # echo "Compilation successful. Running the program..."

    # Set the maximum memory limit to 512MB
    ulimit -v $memory_limit  # 512 MB in KB

    # Get the current process ID
    current_pid=$$

    # echo "Current Process ID: $current_pid"

    # Start timing
    start=$(($(date +%s%N)/1000000))  # Get the start time in milliseconds

    # Run the program with a timeout of 5 seconds
    output=$(timeout $time_limit "$dir/bin/$base.out" 2>&1)  # Run the program with a timeout of 5 seconds
    exit_code=$?  # Capture the exit code

    # End timing
    end=$(($(date +%s%N)/1000000))  # Get the end time in milliseconds

    # Calculate elapsed time in milliseconds
    elapsed=$((end - start))

    # Check if the program timed out
    # 
    if [ -f core ]; then
        echo -e "${RED}Error: The program crashed and created a core dump.${RESET}"
        echo "You can analyze the core dump with gdb."
        rm core >/dev/null 2>&1  # Remove core dump file after handling, suppress output
    elif [ $exit_code -eq 124 ]; then
        echo -e ${RED}"TLE: Time Limit Exceeded"${RESET}
    elif [ $exit_code -eq 139 ]; then
        echo -e "${RED}MLE: Memory Limit Exceeded.${RESET}"
    elif [ $exit_code -ne 0 ]; then
        echo -e "${RED}$output${RESET}"
        echo -e "${RED}Program terminated with exit code: $exit_code${RESET}"
    else
        # Print the output of the program
        if [ -n "$output" ]; then
                echo "$output"
        fi
        # Display the execution time
        # echo "Execution time: ${elapsed} ms"
        echo -e "${GREEN}Execution Time: ${elapsed} ms${RESET}"
    
        # Display memory usage
        mem_usage=$(ps -o rss= -p $current_pid)  # Get the memory usage of the last process
        # Convert KB to MB if greater than 1024
        if [ "$mem_usage" -gt 1024 ]; then
            mem_usage_mb=$((mem_usage / 1024))  # Integer division in bash
            mem_usage_decimal=$(( (mem_usage % 1024) * 100 / 1024 ))  # Calculate decimal part
            # echo "Memory used: ${mem_usage_mb}.${mem_usage_decimal} MB"
            echo -e "${GREEN}Memory Used: ${mem_usage_mb}.${mem_usage_decimal} MB${RESET}"
        else
            echo "${GREEN}Memory used: ${mem_usage} KB${RESET}"
        fi
    fi  
    
    # Clean up the output file
    rm "$dir/bin/$base.out"  # Delete the output file after execution
else
    echo -e "${RED}Compilation failed.${RESET}"
fi

# After handling the output and before exiting
if [ -d "$dir/bin" ] && [ -z "$(ls -A "$dir/bin")" ]; then
    rmdir "$dir/bin"
    # echo -e "Removed empty bin folder"
fi
