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

# Accept build arguments TARGET and DATAFILE, default DATAFILE to 'circle-N1000-D2.in'
ARG TARGET=c-serial
ARG DATAFILE=circle-N1000-D2.in
ENV TARGET=${TARGET}
ENV DATAFILE=${DATAFILE}

# Build and run the Rust executable with timing and the specified datafile
CMD make "$TARGET" datafile="$DATAFILE"