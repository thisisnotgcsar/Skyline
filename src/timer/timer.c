/**
 * timer.c
 * Measures the execution time of an external executable.
 * Usage:
 *   ./timer <executable> [args...]
 * Example:
 *   ./timer /workspace/src/rust/target/release/rust < inputfile
 * Notes:
 *   - Arguments after <executable> are passed to the external program.
 *   - Any shell redirection (e.g., < inputfile) is handled by the shell before this program runs.
 *   - Uses fork/execvp to run the external program and measures elapsed time.
 */

#include "hpc.h"
#include <fcntl.h>    // For open
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h> // For waitpid and macros
#include <unistd.h>   // For fork, execvp

int main(int argc, char* argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <executable> [args...]\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Start timing before launching the child process
    double tstart = hpc_gettime();

    pid_t pid = fork();
    if (pid < 0) {
        // Fork failed
        perror("fork");
        return EXIT_FAILURE;
    } else if (pid == 0) {
        // Child process: execute the external program
        freopen("/dev/null", "w", stdout);
        execvp(argv[1], &argv[1]);
        // If execvp returns, there was an error launching the program
        perror("execvp");
        exit(127);
    }

    // Parent process: wait for the child to finish
    int status = 0;
    if (waitpid(pid, &status, 0) < 0) {
        perror("waitpid");
        return EXIT_FAILURE;
    }
    // Stop timing after child finishes
    double elapsed = hpc_gettime() - tstart;

    // Check if child exited successfully
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        fprintf(stderr, "External command failed: %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    // Print the measured execution time
    fprintf(stderr, "\nExecution time %f seconds\n", elapsed);
    return EXIT_SUCCESS;
}
