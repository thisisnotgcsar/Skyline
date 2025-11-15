# Use official Rust image
FROM rust:latest

# Install C build tools, useful utilities, OpenMP (via GCC), and MPI (mpich), and rbox (from qhull)
RUN apt-get update && \
    apt-get install -y build-essential make gcc g++ vim git qhull-bin mpich && \
    rm -rf /var/lib/apt/lists/*

# Set up workspace directory to match VS Code dev container
WORKDIR /workspace/

# Copy all project files to workspace
COPY . /workspace/

# Accept build arguments TARGET, DATAFILE, and SILENCE
ARG TARGET=c-serial
ARG DATAFILE=circle.in
ARG SILENCE=0
ARG VERBOSE=0
ENV TARGET=${TARGET}
ENV DATAFILE=${DATAFILE}
ENV SILENCE=${SILENCE}
ENV VERBOSE=${VERBOSE}

# Build and run the selected executable with timing and the specified datafile
CMD if [ "$VERBOSE" = "1" ]; then make "$TARGET" datafile="$DATAFILE"; else make --silent "$TARGET" datafile="$DATAFILE"; fi