#!/bin/bash

# -----------------------------------------------------------------------------
# Skyline Container Runner Script
# This script builds the Docker image with the specified requirements,
# runs the container, executes the selected implementation on the chosen datafile,
# displays output and timing information, and deletes all files created inside the container.
# Note: CUDA implementation requires NVIDIA Docker runtime (nvidia-docker2) and a compatible GPU.
# -----------------------------------------------------------------------------

# Get implementation targets from main Makefile
IMPLEMENTATION_TARGETS=$(awk '/^\.PHONY:/ {for(i=2;i<=NF;i++) print $i}' ./Makefile)

# Get all individual possible targets from datafiles/Makefile (excluding .PHONY, all, clean)
DATAFILE_TARGETS=$(awk '/^[a-zA-Z0-9_-]+:/{print $1}' ./datafiles/Makefile | sed 's/:$//' | grep -vE '^(all|clean|\.PHONY|NPOINTS:=100000)$')

# Parse arguments for silence and verbose flags
VERBOSE=0
SILENCE=0
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --silence|-s)
            SILENCE=1
            ;;
        --verbose|-v)
            VERBOSE=1
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

# Set implementation and datafile targets (with defaults)
TARGET="${ARGS[0]:-c-serial}"
DATAFILE_TARGET="${ARGS[1]:-circle}"

# Show help message
if [[ "$TARGET" == "-h" || "$TARGET" == "--help" ]]; then
    echo "Usage: $0 [IMPLEMENTATION_TARGET] [DATAFILE_TARGET] [--silence|-s] [--verbose|-v]"
    echo
    echo "This script will:"
    echo "  - Build the Docker image with the requirements specified by your arguments."
    echo "  - Run the container and execute the selected implementation on the chosen datafile."
    echo "  - Display the output and timing information."
    echo "  - Automatically delete all files created inside the container after execution."
    echo
    echo "Note: CUDA target requires NVIDIA Docker runtime and a compatible GPU."
    echo
    echo "Arguments:"
    echo "  IMPLEMENTATION_TARGET: One of the following (default: c-serial):"
    echo "$IMPLEMENTATION_TARGETS"
    echo
    echo "  DATAFILE_TARGET: One of the following (default: circle):"
    echo "$DATAFILE_TARGETS"
    echo
    echo "  --silence or -s: If set, silences the output of the executable."
    echo "  --verbose or -v: If set, shows all Docker and Makefile logs."
    exit 0
fi

# Validate implementation target
if ! echo "$IMPLEMENTATION_TARGETS" | grep -qx "$TARGET"; then
    echo "Error: '$TARGET' is not a valid implementation target."
    echo "Valid targets are: $IMPLEMENTATION_TARGETS"
    exit 1
fi

# Validate datafile target
if ! echo "$DATAFILE_TARGETS" | grep -qx "$DATAFILE_TARGET"; then
    echo "Error: '$DATAFILE_TARGET' is not a valid datafile target."
    echo "Valid datafile targets are: $DATAFILE_TARGETS"
    exit 1
fi

# Remove container and image if they exist
if [ "$VERBOSE" -eq 1 ]; then
    # Show Docker cleanup logs
    docker rm -f skyline-dev-container 2>/dev/null
    docker rmi -f skyline-dev-image:latest 2>/dev/null
else
    # Suppress Docker cleanup logs
    docker rm -f skyline-dev-container 2>/dev/null 1>/dev/null
    docker rmi -f skyline-dev-image:latest 2>/dev/null 1>/dev/null
fi

# Build Docker image with the specified arguments
if [ "$VERBOSE" -eq 1 ]; then
    # Show Docker build logs
    docker build --build-arg TARGET="$TARGET" --build-arg DATAFILE="$DATAFILE_TARGET" --build-arg SILENCE="$SILENCE" --build-arg VERBOSE="$VERBOSE" -t skyline-dev-image:latest .
else
    # Suppress Docker build logs
    docker build -q --build-arg TARGET="$TARGET" --build-arg DATAFILE="$DATAFILE_TARGET" --build-arg SILENCE="$SILENCE" --build-arg VERBOSE="$VERBOSE" -t skyline-dev-image:latest . 1>/dev/null
fi

# Run the container and display output/timing info
# Use --gpus all flag if target is cuda
if [[ "$TARGET" == "cuda" ]]; then
    docker run --rm --gpus all skyline-dev-image
else
    docker run --rm skyline-dev-image
fi