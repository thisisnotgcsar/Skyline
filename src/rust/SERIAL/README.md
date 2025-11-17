# Rust Serial Skyline Implementation

## Overview
This directory contains a sequential Rust implementation of the skyline algorithm. This implementation demonstrates Rust's memory safety guarantees and modern language features while providing a baseline for comparing with the parallel Rust implementation.

## Algorithm Details
The Rust serial implementation computes the skyline using:
1. **Input Parsing**: Reads point data from standard input with error handling
2. **Sequential Dominance Checking**: Uses nested iteration with Rust iterators
3. **Functional Style**: Leverages Rust's iterator combinators for concise code
4. **Output Generation**: Prints non-dominated points with formatted output

### Algorithm Design
- **Memory Safety**: No unsafe code, all memory operations are checked at compile time
- **Zero-Cost Abstractions**: Iterator chains compile to efficient machine code
- **Error Handling**: Proper Result and Option types for robust error handling

## Building

### Prerequisites
- Rust toolchain (rustc, cargo) - version 1.70 or later recommended
- Standard development tools

### Build Commands
```bash
# From the SERIAL directory
cargo build --release

# Or from the project root
make rust-serial
```

The `--release` flag enables optimizations for production-level performance.

## Running
```bash
# Run with input redirection
./target/release/rust-serial < ../../datafiles/input.in > output.out

# Or using cargo run
cargo run --release < ../../datafiles/input.in

# Or using the timer utility from project root
./src/timer/timer src/rust/SERIAL/target/release/rust-serial < datafiles/input.in
```

## Performance Considerations
- Comparable or better performance than C serial implementation due to LLVM optimizations
- Zero-cost abstractions mean high-level code compiles to efficient machine code
- Memory safety guarantees with no runtime overhead
- Excellent baseline for measuring parallel Rust implementation speedup

## Project Structure
```
SERIAL/
├── Cargo.toml          # Rust package manifest
├── src/
│   └── main.rs         # Main implementation
├── Makefile            # Build wrapper for integration
└── README.md           # This file
```

## Cargo Configuration
The `Cargo.toml` file configures:
- Package metadata (name, version, edition)
- Dependencies (if any)
- Build profiles (release optimizations)

## Files
- `Cargo.toml`: Rust package manifest
- `src/main.rs`: Main serial implementation
- `Makefile`: Wrapper for cargo build commands
- `README.md`: This file
