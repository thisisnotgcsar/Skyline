# MPI Skyline Implementation

## Overview
This directory contains an MPI-based distributed parallel implementation of the skyline algorithm. The implementation leverages multiple processes across potentially multiple machines to compute skyline points from large datasets.

## Algorithm Details
The MPI implementation parallelizes the skyline computation by:
1. **Data Distribution**: Broadcasting the entire dataset to all processes
2. **Work Partitioning**: Dividing points among processes for dominance checking
3. **Parallel Dominance Checking**: Each process checks its assigned subset of points
4. **Result Gathering**: Collecting skyline membership results from all processes to the root
5. **Output Generation**: Root process outputs the final skyline points

### Communication Pattern
- **Broadcast**: Dataset is broadcast from root (rank 0) to all processes
- **Gather**: Results are gathered back to the root process
- **All-to-All**: Each process needs access to all points for dominance checking

## Building

### Prerequisites
- MPI implementation (MPICH or OpenMPI)
- GCC compiler
- Make build system

### Build Commands
```bash
# From the MPI directory
make

# Or from the project root
make mpi
```

## Running
```bash
# Run with 4 processes using input redirection
mpirun -np 4 ./mpi-skyline < ../../datafiles/input.in > output.out

# Or using the timer utility from project root
mpirun -np 4 ./src/timer/timer src/C/MPI/mpi-skyline < datafiles/input.in

# Run on multiple nodes (with hostfile)
mpirun -np 8 -hostfile hosts.txt ./mpi-skyline < ../../datafiles/input.in
```

## Performance Considerations
- Scales across multiple machines in a cluster environment
- Best suited for very large datasets where distributed computation is beneficial
- Communication overhead can be significant for small datasets
- Performance depends on network bandwidth and latency between nodes
- Broadcasting entire dataset may become a bottleneck for very large data

## MPI Configuration
- **Process Count**: Use `-np N` flag with mpirun to specify number of processes
- **Host Distribution**: Use `-hostfile` to distribute processes across multiple machines
- **Process Binding**: Consider using process/core binding for NUMA architectures

## Files
- `mpi-skyline.c`: Main MPI implementation
- `Makefile`: Build configuration with MPI compiler wrappers
- `README.md`: This file

## Reused Components
This implementation reuses the common utilities from `../common/`:
- `skyline_utils.h`: Header with data structures and function declarations
- `skyline_utils.c`: Implementation of I/O and utility functions
- Shared library linked during compilation
