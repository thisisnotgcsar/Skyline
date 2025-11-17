# OpenMP Skyline Implementation

## Overview
This directory contains an OpenMP-based parallel implementation of the skyline algorithm. The implementation uses shared-memory parallelization to accelerate the computation of skyline points on multi-core processors.

## Algorithm Details
The OpenMP implementation parallelizes the skyline computation by:
1. **Input Reading**: Reads point data from standard input (sequential)
2. **Parallel Dominance Checking**: Distributes outer loop iterations across threads using OpenMP directives
3. **Thread-Safe Updates**: Uses atomic operations or critical sections to safely update the skyline membership array
4. **Output Generation**: Prints all non-dominated points (sequential)

### Parallelization Strategy
- **Work Distribution**: The outer loop over points is parallelized using `#pragma omp parallel for`
- **Synchronization**: Minimal synchronization overhead with thread-local computations
- **Load Balancing**: Dynamic or static scheduling can be configured for optimal performance

## Building

### Prerequisites
- GCC compiler with OpenMP support (gcc 4.2 or later)
- Make build system

### Build Commands
```bash
# From the OMP directory
make

# Or from the project root
make openmp
```

## Running
```bash
# Run with input redirection
./omp-skyline < ../../datafiles/input.in > output.out

# Or using the timer utility from project root
./src/timer/timer src/C/OMP/omp-skyline < datafiles/input.in

# Set number of threads
OMP_NUM_THREADS=4 ./omp-skyline < ../../datafiles/input.in
```

## Performance Considerations
- Scales well with the number of CPU cores
- Best suited for medium to large datasets where parallelization overhead is amortized
- Performance depends on the number of available cores and thread scheduling
- Shared memory architecture limits scalability compared to distributed implementations

## Environment Variables
- `OMP_NUM_THREADS`: Set the number of OpenMP threads (default: system-dependent)
- `OMP_SCHEDULE`: Configure scheduling policy (static, dynamic, guided)

## Files
- `omp-skyline.c`: Main OpenMP implementation
- `Makefile`: Build configuration with OpenMP flags
- `README.md`: This file

## Reused Components
This implementation reuses the common utilities from `../common/`:
- `skyline_utils.h`: Header with data structures and function declarations
- `skyline_utils.c`: Implementation of I/O and utility functions
- Shared library linked during compilation
