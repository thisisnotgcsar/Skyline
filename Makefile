## If you decide to use this makefile, the "make" command should
## compile all submitted programs without errors or warnings. It is
## therefore recommended to remove any targets not present
## in the submitted archive.
##
## This Makefile compiles "omp-*.c" files using the -fopenmp flag, 
## "cuda-*.cu" files with the nvcc compiler, and "mpi-*.c" files with
## mpicc.
##
## The main targets defined by this makefile are:
##
## make         compiles all available sources
## make clean   deletes temporary files and executables
## make openmp  compiles the OpenMP version
## make mpi     compiles the MPI version
## make cuda    compiles the CUDA version

EXE_OMP:=$(basename $(wildcard omp-*.c))
EXE_MPI:=$(basename $(wildcard mpi-*.c))
EXE_CUDA:=$(basename $(wildcard cuda-*.cu))
EXE_TIMER:=src/timer/timer
EXE_RUST_SERIAL:=src/rust/SERIAL/target/release/rust
EXE_C_SERIAL:=src/C/SERIAL/skyline
EXE:=$(EXE_TIMER) $(EXE_OMP) $(EXE_MPI) $(EXE_C_SERIAL) $(EXE_CUDA) $(EXE_RUST_SERIAL)

CFLAGS+=-std=c99 -Wall -Wpedantic -O2 -D_XOPEN_SOURCE=600
LDLIBS+=-lm
NVCC:=nvcc
NVCFLAGS+=-Wno-deprecated-gpu-targets
NVLDLIBS+=-lm

.PHONY: clean

ALL: $(EXE)

$(EXE_TIMER):
	$(MAKE) -C src/timer

% : %.cu
    $(NVCC) $(NVCFLAGS) $< -o $@ $(NVLDLIBS)

$(EXE_OMP): CFLAGS+=-fopenmp
openmp: $(EXE_TIMER) $(EXE_OMP)

$(EXE_MPI): CC=mpicc
mpi: $(EXE_TIMER) $(EXE_MPI)

cuda: $(EXE_TIMER) $(EXE_CUDA)

rust-serial: $(EXE_TIMER)
	./$(EXE_TIMER) $(EXE_RUST_SERIAL)

clean:
    \rm -f $(EXE) *.o *~

print-exe:
	@echo $(EXE_C_SERIAL)
