# MPI Skyline Makefile

MPICC = mpicc
CFLAGS = -std=c99 -Wall -Wpedantic -O2

all: mpi-skyline

mpi-skyline: mpi-skyline.c
	$(MPICC) $(CFLAGS) -o $@ $^

clean:
	\rm -f mpi-skyline *.o *~
