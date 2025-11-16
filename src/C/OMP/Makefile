# OpenMP Skyline Makefile

CFLAGS = -std=c99 -Wall -Wpedantic -O2 -fopenmp

all: omp-skyline

omp-skyline: omp-skyline.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	\rm -f omp-skyline *.o *~
