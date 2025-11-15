"""
plot_skyline_times.py

This script runs the Skyline benchmark via the shell script, parses execution times for each implementation,
and displays them in a bar graph for easy comparison.

How it works:
- Reads all valid datafile targets from the Makefile.
- Accepts a datafile target as a command-line argument (default: circle).
- Runs './skyline.sh all <DATAFILE_TARGET> --silence' to benchmark all implementations.
- Parses the output for execution times.
- Plots a bar graph and saves it as 'results/skyline_times_<datafile_target>.png'.

Usage:
    python3 plot_skyline_times.py [--help|-h] [DATAFILE_TARGET]

Arguments:
    DATAFILE_TARGET   One of the valid datafile targets from the Makefile (default: circle).
    --help, -h        Show this help message and exit.

Example:
    python3 plot_skyline_times.py test3
"""

import subprocess
import re
import sys
import matplotlib.pyplot as plt
import os


def get_datafile_targets():
    """
    Reads all valid datafile targets from the datafiles/Makefile.
    Returns a list of target names.
    """
    try:
        # Use a raw string to avoid SyntaxWarning for escape sequences
        output = subprocess.check_output(
            r"awk '/^[a-zA-Z0-9_-]+:/{print $1}' ./datafiles/Makefile | sed 's/:$//' | grep -vE '^(all|clean|\.PHONY|NPOINTS:=100000)$'",
            shell=True,
            text=True,
        )
        targets = output.strip().split("\n")
        return [t for t in targets if t]
    except Exception:
        return ["circle"]


def print_help(targets):
    """
    Prints the script's docstring and lists valid datafile targets.
    """
    print(__doc__)
    print("Valid DATAFILE_TARGET values:")
    for t in targets:
        print(f"  - {t}")


def run_skyline(datafile_target):
    """
    Runs the Skyline shell script with 'all', the selected datafile target, and '--silence'.
    Captures and returns the stderr output (where timer prints execution times).
    """
    proc = subprocess.run(
        ["./skyline.sh", "all", datafile_target, "--silence"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return proc.stderr


def parse_times(stderr):
    """
    Parses the stderr output for execution time lines.
    Returns two lists: implementation labels and their corresponding times.
    """
    pattern = r"Execution time for ([^:]+): ([0-9.]+) seconds"
    results = re.findall(pattern, stderr)
    labels = []
    times = []
    for exe, sec in results:
        labels.append(exe.split("/")[-1])
        times.append(float(sec))
    return labels, times


def plot_times(labels, times, datafile_target):
    """
    Plots a bar graph of execution times for each implementation and saves it as 'results/skyline_times_<datafile_target>.png'.
    """
    os.makedirs("results", exist_ok=True)
    plt.figure(figsize=(8, 4))
    plt.bar(labels, times, color="skyblue")
    plt.ylabel("Execution Time (seconds)")
    plt.title(
        f"Skyline Benchmark: Execution Time per Implementation\nDatafile: {datafile_target}"
    )
    plt.xticks(rotation=30)
    plt.tight_layout()
    filename = f"results/skyline_times_{datafile_target}.png"
    plt.savefig(filename)


if __name__ == "__main__":
    datafile_targets = get_datafile_targets()
    # Parse arguments
    if len(sys.argv) > 1 and sys.argv[1] in ("--help", "-h"):
        print_help(datafile_targets)
        sys.exit(0)
    datafile_target = sys.argv[1] if len(sys.argv) > 1 else "circle"
    if datafile_target not in datafile_targets:
        print(f"Error: '{datafile_target}' is not a valid DATAFILE_TARGET.\n")
        print_help(datafile_targets)
        sys.exit(1)
    # Run the Skyline benchmark and parse results
    stderr = run_skyline(datafile_target)
    labels, times = parse_times(stderr)
    if not labels:
        print("No execution times found. Check script output.")
    else:
        plot_times(labels, times, datafile_target)
        print(
            f"Plot saved as results/skyline_times_{datafile_target}.png for datafile target '{datafile_target}'."
        )
