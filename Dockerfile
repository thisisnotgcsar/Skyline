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

# Build and run the Rust serial executable with timing and the simplest datafile
CMD ["make", "rust-serial", "datafile=circle-N1000-D2.in"]