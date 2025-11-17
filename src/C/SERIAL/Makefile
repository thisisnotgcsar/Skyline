CC = gcc
CFLAGS = -std=c99 -Wall -Wpedantic -O2 -D_XOPEN_SOURCE=600

TARGET = c-serial
LIB = skyline_utils
LIB_DIR = ../common
LIB_PATH = $(LIB_DIR)/$(LIB)

OBJS = $(TARGET).o $(LIB_DIR)/$(LIB).o

all: $(TARGET)

# Linking with the static library archive
$(TARGET): $(TARGET).o $(LIB_PATH).a
	$(CC) $(CFLAGS) -o $@ $(TARGET).o $(LIB_PATH).a

$(TARGET).o: $(TARGET).c $(LIB_DIR)/$(LIB).h
	$(CC) $(CFLAGS) -I$(LIB_DIR) -c $(TARGET).c -o $(TARGET).o

# creating the static library
$(LIB_PATH).a:
	$(MAKE) -C $(LIB_DIR)

.PHONY: all clean

clean:
	rm -f $(TARGET) $(TARGET).o
	$(MAKE) -C $(LIB_DIR) clean