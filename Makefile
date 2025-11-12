# -----------------------------------------------------------------------------
# Top-level Makefile for the Skyline project.
# This Makefile builds all subprojects and utilities, including:
#   - OpenMP, MPI, CUDA, and serial C executables
#   - Rust serial executable
#   - Timer utility for measuring execution time
#   - Datafiles for input testing
# Each subproject may have its own Makefile.
# -----------------------------------------------------------------------------

# Collect executable names for each subproject
# OpenMP executables
EXE_OMP:=$(basename $(wildcard omp-*.c))
# MPI executables
EXE_MPI:=$(basename $(wildcard mpi-*.c))
# CUDA executables
EXE_CUDA:=$(basename $(wildcard cuda-*.cu))
# Timer utility
EXE_TIMER:=src/timer/timer
# Rust serial executable
EXE_RUST_SERIAL:=src/rust/SERIAL/target/release/rust
# C serial executable
EXE_C_SERIAL:=src/C/SERIAL/skyline
# Directory for input datafiles
DATAFILES_DIR:=datafiles

# Compiler and linker flags
CFLAGS += -std=c99 -Wall -Wpedantic -O2 -D_XOPEN_SOURCE=600
LDLIBS += -lm
NVCC := nvcc
NVCFLAGS += -Wno-deprecated-gpu-targets
NVLDLIBS += -lm

.PHONY: clean datafiles exe_timer prereq run_timer ALL

# Build all datafiles or a specific one if 'datafile' variable is set
datafiles:
	$(MAKE) -C $(DATAFILES_DIR) $(if $(datafile),$(datafile),all)

# Build the timer utility
exe_timer:
	$(MAKE) -C src/timer

# Build prerequisites: datafiles and timer utility
prereq: datafiles exe_timer

# Run the timer utility on the given executable and input datafiles.
# Loop over all .in files.
run_timer: prereq
	@for f in $(wildcard $(DATAFILES_DIR)/*.in); do \
		[ -f "$$f" ] && ./$(EXE_TIMER) $(EXE) < "$$f"; \
	done

# Build all main executables and prerequisites
ALL: prereq openmp mpi cuda rust-serial c-serial

# Build OpenMP executables (with prerequisites)
openmp: prereq $(EXE_OMP)
	$(MAKE) run_timer EXE=$(EXE_OMP)

# Build MPI executables (with prerequisites)
mpi: prereq $(EXE_MPI)
	$(MAKE) run_timer EXE=$(EXE_MPI)

# Build CUDA executables (with prerequisites)
cuda: prereq $(EXE_CUDA)
	$(MAKE) run_timer EXE=$(EXE_CUDA)

# Build Rust serial executable and run timer on it with input datafiles
rust-serial: prereq
	$(MAKE) -C src/rust/SERIAL
	$(MAKE) run_timer EXE=$(EXE_RUST_SERIAL)

c-serial: prereq
	$(MAKE) -C src/C/SERIAL
	$(MAKE) run_timer EXE=$(EXE_C_SERIAL)

# Remove all build artifacts
clean:
	\rm -f $(EXE) *.o *~ # Remove all build artifacts
