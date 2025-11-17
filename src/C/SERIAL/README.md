# Serial C Skyline Implementation

## Overview
This directory contains a sequential (serial) C implementation of the skyline algorithm. This implementation serves as the baseline for comparing parallel implementations and uses a straightforward nested-loop approach.

## Algorithm Details
The serial implementation computes the skyline using:
1. **Input Reading**: Reads point data from standard input
2. **Sequential Dominance Checking**: For each point `i`, checks all other points `j` to determine if `i` is dominated
3. **Output Generation**: Prints all non-dominated points to standard output

### Algorithm Complexity
- **Time Complexity**: O(N² × D) where N is the number of points and D is the number of dimensions
- **Space Complexity**: O(N × D) for storing the dataset

## Building

### Prerequisites
- GCC compiler (or any C99-compliant compiler)
- Make build system

### Build Commands
```bash
# From the SERIAL directory
make

# Or from the project root
make c-serial
```

## Running
```bash
# Run with input redirection
./c-serial < ../../datafiles/input.in > output.out

# Or using the timer utility from project root
./src/timer/timer src/C/SERIAL/c-serial < datafiles/input.in
```

## Performance Considerations
- Best suited as a baseline for performance comparisons
- Simple and straightforward implementation
- No parallelization overhead makes it competitive for small datasets
- Performance degrades quadratically with dataset size

## Files
- `c-serial.c`: Main implementation with sequential skyline computation
- `Makefile`: Build configuration
- `README.md`: This file

## Reused Components
This implementation reuses the common utilities from `../common/`:
- `skyline_utils.h`: Header with data structures and function declarations
- `skyline_utils.c`: Implementation of I/O and utility functions
- Shared library linked during compilation
