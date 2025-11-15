# MPI Skyline Makefile

MPICC = mpicc
CFLAGS = -std=c99 -Wall -Wpedantic -O2
LDLIBS = -lm

all: mpi-skyline

mpi-skyline: mpi-skyline.c
	$(MPICC) $(CFLAGS) -o $@ $^ $(LDLIBS)

clean:
	\rm -f mpi-skyline *.o *~
