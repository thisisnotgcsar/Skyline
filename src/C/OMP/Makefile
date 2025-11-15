# OpenMP Skyline Makefile

CFLAGS = -std=c99 -Wall -Wpedantic -O2 -fopenmp
LDLIBS = -lm

all: omp-skyline

omp-skyline: omp-skyline.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

clean:
	\rm -f omp-skyline *.o *~
