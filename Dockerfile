# Use official Rust image
FROM rust:latest

# Install C build tools, useful utilities, and rbox (from qhull)
RUN apt-get update && \
    apt-get install -y build-essential make gcc g++ vim git qhull-bin && \
    rm -rf /var/lib/apt/lists/*

# Set up workspace directory to match VS Code dev container
WORKDIR /workspace/

# Copy all project files to workspace
COPY . /workspace/

# Build all input test datafiles
RUN make -C /workspace/datafiles circle-N1000-D2.in

# Build the Rust project
WORKDIR /workspace/src/rust
RUN cargo build --release

# Run the Rust binary with a sample datafile as input
CMD ["/bin/bash", "-c", "/workspace/src/rust/target/release/rust < /workspace/datafiles/circle-N1000-D2.in"]