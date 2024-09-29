# cpp-compile-help
This script compiles your cpp code and displays time and memory taken along with MLE and TLE. <br>
Improves your productivity, so that you spend more time on coding, rather than compiling.<br>
<br>
**Note** that this script has been tested for Linux and does not guarentee about other OS. <br>

## Getting Started

### Setting up
#### If you have git installed
- Open terminal and type: `git clone https://github.com/dipanshu-m/cpp-compile-help.git`
#### Else:
- Paste this in a new tab of your browser: `https://github.com/dipanshu-m/cpp-compile-help/archive/refs/heads/main.zip`. <br>
  This would download a zipped file. unzip it after the download is complete. If asked, set the folder name to `cpp-compile-help`.

#### After cloning/ extraction
* Now, move into the directory by `cd cpp-compile-help`
* Assign permissions by `chmod +x ./cpp_compile.sh`

You can now compile the files using the command `cpp_compile path/to/cpp/file.cpp`

### Setup for global use
For this, we would need to create an alias for ~/.bashrc or ~/.zshrc
For additional security, we would also store the script in a remote location so that we do not delete the file accidentaly.

* Locate to the folder 'cpp-compile-help' and open terminal
* Type `mkdir -p ~/scripts`. This would create a folder with name`scripts` in the home directory if not already exists and would ignore any errors if the directory already exists.
* Now type `mv ./cpp-compile-help ~/scripts`. This will transfer all the contents of the file(including the folder) to the scripts directory.
* Locate to ~/.bashrc or ~/.zshrc and open the file using any text editor and append the following code: <br>
```bash
alias compilecpp='~/scripts/cpp-compile-help/compile_cpp.sh'

compilecpp() {
	~/scripts/cpp-compile-help/compile_cpp.sh "$@"
}
```

* Save the file and close it
* Open terminal and type `source ~/.bashrc or ~/.zshrc to fetch new aliases from bash or zsh profile
* Now, type `compilecpp -h` to verify its setup.

## Usage:

### Syntax: 
```bash
./compile_cpp.sh [options] <filename.cpp>
```

### Options:
* `-h`,` --help`: Show this help message

This script compiles and runs a C++ file, displaying the execution time
and memory usage. It sets a maximum execution time of 5 seconds and a
maximum memory limit of 512 MB.

### Examples:
* ```bash
  ./compile_cpp.sh path/to/my_cpp_program.cpp
  ```
* ```bash
  ./compile_cpp.sh --help
  ```

**Note: You can replace** `./compile_cpp.sh` **with** `compilecpp` **if you have completed the global setup.**

## Personalise  
To personalize this tool upon your needs, you may perform following operations.

### Set Time Limit
By default it is 5 seconds, you may reduce it to 1 second, or maybe 2 seconds, depending upon you.
To modify:
* Find this line `time_limit=5` (line 45)
* Now, modify `5` to any other **integer value > 1**. where the unit is **seconds**.

### Set Memory Limit
By default it is 512MB, you may reduce it to 128MB , or maybe 256MB, depending upon you
To modify:
* Find this line: `memory_limit=524288` (line 46)
* Now, modify `524288` to any other **integer value > 100**. where the unit is **kilobytes**.

## Contributing to this tool
* Open a PR, and once I test it, I will approve it.
* You may also assign an issue to yourself, work on it and link a PR.
