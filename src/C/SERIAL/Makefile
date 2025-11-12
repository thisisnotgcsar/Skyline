CC = gcc
CFLAGS = -std=c99 -Wall -Wpedantic -O2 -D_XOPEN_SOURCE=600
LDLIBS = -lm

skyline: skyline.c
	$(CC) $(CFLAGS) $< -o $@ $(LDLIBS)

clean:
	rm -f skyline *.o *~
