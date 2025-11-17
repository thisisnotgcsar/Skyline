# -----------------------------------------------------------------------------
# Makefile for building the timer executable.
# This Makefile compiles timer.c into 'timer', a utility to measure execution
# time of external executables.
# -----------------------------------------------------------------------------

EXE_TIMER:=timer

all: $(EXE_TIMER)

$(EXE_TIMER): timer.c
	$(CC) -std=c99 -Wall -O2 timer.c -o $(EXE_TIMER)

clean:
	\rm -f $(EXE_TIMER) *.o *~