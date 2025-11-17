# Rust Parallel Skyline Implementation

## Overview
This directory contains a parallel Rust implementation of the skyline algorithm using the Rayon data parallelism library. This implementation demonstrates Rust's fearless concurrency model and achieves significant performance improvements over the serial version.

## Algorithm Details
The Rust parallel implementation parallelizes the skyline computation using:
1. **Input Parsing**: Reads point data from standard input with error handling
2. **Parallel Dominance Checking**: Uses Rayon's parallel iterators for automatic work distribution
3. **Thread-Safe Operations**: Leverages Rust's ownership system to guarantee data-race freedom at compile time
4. **Output Generation**: Collects and prints non-dominated points

### Parallelization Strategy
- **Rayon Library**: Uses `par_iter()` to automatically parallelize iterator chains
- **Work Stealing**: Rayon's work-stealing scheduler ensures good load balancing
- **No Data Races**: Rust's type system prevents data races at compile time
- **Automatic Scaling**: Adapts to available CPU cores without manual configuration

## Building

### Prerequisites
- Rust toolchain (rustc, cargo) - version 1.70 or later recommended
- Standard development tools

### Build Commands
```bash
# From the PARALLEL directory
cargo build --release

# Or from the project root
make rust-parallel
```

The `--release` flag enables optimizations including auto-vectorization.

## Running
```bash
# Run with input redirection
./target/release/rust-parallel < ../../datafiles/input.in > output.out

# Or using cargo run
cargo run --release < ../../datafiles/input.in

# Or using the timer utility from project root
./src/timer/timer src/rust/PARALLEL/target/release/rust-parallel < datafiles/input.in

# Control thread pool size
RAYON_NUM_THREADS=4 ./target/release/rust-parallel < ../../datafiles/input.in
```

## Performance Considerations
- Excellent scaling with number of CPU cores
- Very low parallelization overhead compared to OpenMP
- Work-stealing scheduler provides good load balancing
- Memory safety guarantees without runtime cost
- Often outperforms C/OpenMP implementations due to better optimizations

## Environment Variables
- `RAYON_NUM_THREADS`: Set the number of threads in Rayon's thread pool (default: number of logical CPUs)

## Project Structure
```
PARALLEL/
├── Cargo.toml          # Rust package manifest (includes rayon dependency)
├── src/
│   └── main.rs         # Main parallel implementation
├── Makefile            # Build wrapper for integration
└── README.md           # This file
```

## Dependencies
- **rayon**: Data parallelism library for easy and safe parallel iteration

## Cargo Configuration
The `Cargo.toml` file configures:
- Package metadata (name, version, edition)
- Rayon dependency for parallel iterators
- Release profile with aggressive optimizations

## Files
- `Cargo.toml`: Rust package manifest with rayon dependency
- `src/main.rs`: Main parallel implementation using Rayon
- `Makefile`: Wrapper for cargo build commands
- `README.md`: This file
