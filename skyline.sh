#!/bin/bash

# -----------------------------------------------------------------------------
# Script to build and run the Skyline development Docker container.
# Usage: ./skyline.sh [IMPLEMENTATION_TARGET] [DATAFILE_TARGET]
# - IMPLEMENTATION_TARGET: Optional. One of the Makefile's implementation targets (default: c-serial).
# - DATAFILE_TARGET: Optional. One of the datafile targets (default: circle).
# - Shows valid targets and help if requested or invalid input.
# -----------------------------------------------------------------------------

# Get implementation targets from main Makefile
IMPLEMENTATION_TARGETS=$(awk '/^\.PHONY:/ {for(i=2;i<=NF;i++) print $i}' ./Makefile)

# Get all individual possible targets from datafiles/Makefile (excluding .PHONY, all, clean)
DATAFILE_TARGETS=$(awk '/^[a-zA-Z0-9_-]+:/{print $1}' ./datafiles/Makefile | sed 's/:$//' | grep -vE '^(all|clean|\.PHONY|NPOINTS:=100000)$')

# Show help message
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [IMPLEMENTATION_TARGET] [DATAFILE_TARGET]"
    echo "Build and run the Skyline dev container for a given implementation target and datafile target."
    echo
    echo "IMPLEMENTATION_TARGET: One of the following (default: c-serial):"
    echo "$IMPLEMENTATION_TARGETS"
    echo
    echo "DATAFILE_TARGET: One of the following (default: circle):"
    echo "$DATAFILE_TARGETS"
    exit 0
fi

# Get target from input argument, default to 'c-serial' if not provided
TARGET="${1:-c-serial}"

# Get datafile target from second argument, default to 'circle' if not provided
DATAFILE_TARGET="${2:-circle}"

# Validate target
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

# Remove container if it exists
docker rm -f skyline-dev-container 2>/dev/null

# Remove image if it exists
docker rmi -f skyline-dev-image:latest 2>/dev/null

# Build image with TARGET and DATAFILE_TARGET arguments
docker build --build-arg TARGET="$TARGET" --build-arg DATAFILE="$DATAFILE_TARGET" -t skyline-dev-image:latest .

# Run container
docker run --rm skyline-dev-image