# CUDA Skyline Implementation

## Overview
This directory contains a CUDA-based parallel implementation of the skyline algorithm. The implementation leverages NVIDIA GPU hardware to accelerate the computation of skyline points from multi-dimensional datasets.

## Algorithm Details
The CUDA implementation parallelizes the skyline computation by:
1. **Data Transfer**: Moving point data from CPU (host) to GPU (device) memory
2. **Parallel Dominance Checking**: Each point is assigned to a thread block, and threads within blocks check dominance relationships in parallel
3. **Result Collection**: Transferring the skyline membership results back to CPU memory

### Kernel Design
- **Grid Dimension**: 2D grid where each block along the x-axis handles one point `i`
- **Thread Distribution**: Threads are distributed across blocks along the y-axis to check all points `j`
- **Synchronization**: Atomic operations ensure thread-safe updates to the skyline membership array

## Building

### Prerequisites
- NVIDIA CUDA Toolkit (version 7.0 or later for sm_50 architecture)
- NVIDIA GPU with compute capability 5.0 or higher
- GCC compiler for building the shared utilities

### Build Commands
```bash
# From the CUDA directory
make

# Or from the project root
make cuda
```

## Running
```bash
# Run with input redirection
./cuda-skyline < ../../datafiles/input.in > output.out

# Or using the timer utility from project root
./src/timer/timer src/C/CUDA/cuda-skyline < datafiles/input.in
```

## Architecture Notes
- **Compute Architecture**: Targets sm_50 (Maxwell architecture) and newer
- **Thread Block Size**: 256 threads per block (optimized for good GPU occupancy)
- **Memory Management**: Uses explicit CUDA memory allocation and transfers

## Performance Considerations
- Best suited for datasets with large numbers of points (N > 1000)
- GPU overhead may make CPU implementations faster for very small datasets
- Memory transfer time is a consideration for the total execution time

## Files
- `cuda-skyline.cu`: Main CUDA implementation with kernel and host code
- `Makefile`: Build configuration for CUDA compilation
- `README.md`: This file

## Reused Components
This implementation reuses the common utilities from `../common/`:
- `skyline_utils.h`: Header with data structures and function declarations
- `skyline_utils.c`: Implementation of I/O and utility functions
- Shared library linked during compilation
