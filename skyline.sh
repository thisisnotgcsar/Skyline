#!/bin/bash

# -----------------------------------------------------------------------------
# Script to build and run the Skyline development Docker container.
# Usage: ./refresh_container.sh [PHONY_TARGET] [DATAFILE]
# - PHONY_TARGET: Optional. One of the Makefile's PHONY targets (default: c-serial).
# - DATAFILE: Optional. One of the datafiles (default: circle).
# - Shows valid targets and help if requested or invalid input.
# -----------------------------------------------------------------------------

# Get PHONY targets from main Makefile
PHONY_TARGETS=$(awk '/^\.PHONY:/ {for(i=2;i<=NF;i++) print $i}' ./Makefile)

# Get all individual possible targets from datafiles/Makefile (excluding .PHONY, all, clean)
DATAFILE_TARGETS=$(awk '/^[a-zA-Z0-9_-]+:/{print $1}' ./datafiles/Makefile | sed 's/:$//' | grep -vE '^(all|clean|\.PHONY|NPOINTS:=100000)$')

# Show help message
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [PHONY_TARGET] [DATAFILE]"
    echo "Build and run the Skyline dev container for a given PHONY target and datafile."
    echo
    echo "PHONY_TARGET: One of the following (default: c-serial):"
    echo "$PHONY_TARGETS"
    echo
    echo "DATAFILE: One of the following (default: circle):"
    echo "$DATAFILE_TARGETS"
    exit 0
fi

# Get target from input argument, default to 'c-serial' if not provided
TARGET="${1:-c-serial}"

# Get datafile from second argument, default to 'circle' if not provided
DATAFILE="${2:-circle}"

# Validate target
if ! echo "$PHONY_TARGETS" | grep -qx "$TARGET"; then
    echo "Error: '$TARGET' is not a valid PHONY target."
    echo "Valid targets are: $PHONY_TARGETS"
    exit 1
fi

# Validate datafile
if ! echo "$DATAFILE_TARGETS" | grep -qx "$DATAFILE"; then
    echo "Error: '$DATAFILE' is not a valid datafile target."
    echo "Valid datafile targets are: $DATAFILE_TARGETS"
    exit 1
fi

# Remove container if it exists
docker rm -f skyline-dev-container 2>/dev/null

# Remove image if it exists
docker rmi -f skyline-dev-image:latest 2>/dev/null

# Build image with TARGET and DATAFILE arguments
docker build --build-arg TARGET="$TARGET" --build-arg DATAFILE="$DATAFILE" -t skyline-dev-image:latest .

# Run container
docker run --rm skyline-dev-image