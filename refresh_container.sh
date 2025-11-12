#!/bin/bash

# Remove container if it exists
docker rm -f skyline-dev-container 2>/dev/null

# Remove image if it exists
docker rmi -f skyline-dev-image:latest 2>/dev/null

# Build image
docker build -t skyline-dev-image:latest .

# Run container
docker run --rm skyline-dev-image