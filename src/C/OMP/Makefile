# OpenMP Skyline Makefile

CFLAGS = -std=c99 -Wall -Wpedantic -O2 -fopenmp

TARGET = omp-skyline
LIB = skyline_utils
LIB_DIR = ../common
LIB_PATH = $(LIB_DIR)/$(LIB)

all: $(TARGET)

# Linking the objet file with the static library
$(TARGET): $(TARGET).o $(LIB_PATH).a
	gcc $(CFLAGS) $(TARGET).o $(LIB_PATH).a -o $@

# Creating the object file from the source file without linking
$(TARGET).o: $(TARGET).c $(LIB_DIR)/$(LIB).h
	gcc $(CFLAGS) -I$(LIB_DIR) -c $(TARGET).c -o $(TARGET).o

# creating the static library
$(LIB_PATH).a:
	$(MAKE) -C $(LIB_DIR)

.PHONY: all clean

clean:
	rm -f $(TARGET) $(TARGET).o
	$(MAKE) -C $(LIB_DIR) clean
