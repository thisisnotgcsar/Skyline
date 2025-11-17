# CUDA Skyline Makefile

NVCC = nvcc

TARGET = cuda-skyline
LIB = skyline_utils
LIB_DIR = ../common
LIB_PATH = $(LIB_DIR)/$(LIB)

all: $(TARGET)

# Linking the CUDA object file with the static library
$(TARGET): $(TARGET).o $(LIB_PATH).a
	$(NVCC) $(TARGET).o $(LIB_PATH).a -o $@

# Creating the object file from the CUDA source file without linking
$(TARGET).o: $(TARGET).cu $(LIB_DIR)/$(LIB).h
	$(NVCC) -I$(LIB_DIR) -c $(TARGET).cu -o $(TARGET).o

# Ensure the static library is built with -fPIC
$(LIB_PATH).a:
	$(MAKE) -C $(LIB_DIR)

.PHONY: all clean

clean:
	rm -f $(TARGET) $(TARGET).o
	$(MAKE) -C $(LIB_DIR) clean
