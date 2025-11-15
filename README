# Skyline <!-- omit in toc -->
Skyline is a high-performance computing (HPC) project focused on benchmarking and comparing different parallelization approaches (OpenMP, MPI, CUDA, Rust) for the Skyline problem.  
It includes multiple implementations, input data generators, and a timer utility for performance measurement.

- [1. What is the Skyline](#1-what-is-the-skyline)
- [2. How to Run (Dockerized)](#2-how-to-run-dockerized)
  - [2.1. Makefile Targets](#21-makefile-targets)
  - [2.2. Datafiles Targets](#22-datafiles-targets)
  - [2.3. Plotting Execution Times](#23-plotting-execution-times)
- [3. Directory Structure](#3-directory-structure)
- [4. Contributing](#4-contributing)
- [5. Meta](#5-meta)

# 1. What is the Skyline

The **Skyline** problem is a fundamental computational geometry task.  
Given a set of points in a multi-dimensional space, the goal is to find all points that are **not dominated** by any other point.  
A point *A* dominates point *B* if *A* is as good or better than *B* in all dimensions and strictly better in at least one dimension.

Intuitively, the Skyline is the set of "best choices"—those that are not outperformed by any other option across all criteria.

For example, in a 2D space where each point represents a product with price and quality, the Skyline consists of products that are not both more expensive and lower quality than any other.

![Skyline Example](https://assets.leetcode.com/uploads/2020/12/01/merged.jpg)

---

# 2. How to Run (Dockerized)

This project is **completely dockerized**. You do **not** need to install or uninstall any dependencies on your system.  
All compilation and execution are handled inside a Docker container.

To build and run the project, simply use the provided script:

```sh
./skyline.sh [IMPLEMENTATION_TARGET] [DATAFILE_TARGET] [--silence|-s] [--verbose|-v]
```
- `IMPLEMENTATION_TARGET`: One of the Makefile's implementation targets (default: c-serial)
- `DATAFILE_TARGET`: One of the datafile targets (default: circle)
- `--silence` or `-s`: If set, silences the output of the executable.
- `--verbose` or `-v`: If set, shows all Docker and Makefile logs.

**What happens when you run the script:**
- The Docker image is built with the requirements specified by your arguments.
- The container is run and executes the selected implementation on the chosen datafile.
- Output and timing information are displayed.
- All files created inside the container are automatically deleted after execution.

Example:
```sh
./skyline.sh rust-serial circle
```

The script will automatically build the Docker image, run the container, execute the selected target with the specified datafile target, and clean up after itself.

## 2.1. Makefile Targets

The following targets are available in the Makefile (use as `[IMPLEMENTATION_TARGET]`):

- `c-serial`        : Build and run the serial C implementation
- `openmp`          : Build and run the OpenMP implementation
- `mpi`             : Build and run the MPI implementation
- `rust-serial`     : Build and run the Rust serial implementation
- `rust-parallel`   : Build and run the Rust parallel implementation
- `all`             : Build all executables and prerequisites
- `clean`           : Remove build artifacts

## 2.2. Datafiles Targets

The following datafile targets can be used (use as `[DATAFILE_TARGET]`):

- `circle`    : Small 2D circle (circle.in)
- `test1`     : Surface of a 3D square (test1.in)
- `test2`     : Surface of a 4D sphere (test2.in)
- `test3`     : 10D diamond (test3.in)
- `test4`     : 8D simplex (test4.in)
- `test5`     : 20D sphere (test5.in)
- `test6`     : 50D diamond (test6.in)
- `test7`     : 200D diamond (test7.in)
- `worst`     : Worst-case scenario (worst.in)

> These correspond to targets in `./datafiles/Makefile` and will generate `.in` files for testing.

## 2.3. Plotting Execution Times

A Python script is provided to run all implementations on a selected datafile and visualize their execution times.

**Script:** `plot_skyline_times.py`

**Usage:**
```sh
python3 plot_skyline_times.py [--help|-h] [DATAFILE_TARGET]
```
- `DATAFILE_TARGET`: One of the valid datafile targets (default: `circle`).  
- `--help` or `-h`: Show help and list available datafile targets.

**What it does:**
- Runs `./skyline.sh all <DATAFILE_TARGET> --silence` to benchmark all implementations.
- Parses the output for execution times.
- Plots a bar graph and saves it as `skyline_times.png`.

**Example:**
```sh
python3 plot_skyline_times.py test3
```

**Dependencies:**  
You need `matplotlib` installed. Install it with:
```sh
pip3 install matplotlib
```

---

# 3. Directory Structure

-   `./datafiles/`: input datafile generators and files
-   `./src/`: source code for all implementations
    -   `./C/`: C implementations (serial, OpenMP, MPI, CUDA)
    -   `./rust/`: Rust implementations (serial, parallel)
    -   `./timer/`: Timer utility
-   `results/`: output directory for generated plots and processed datafiles
-   `skyline.sh`: BASH utility script for easy deployment and testing
-   `plot_skyline_times.py`: Python script for plotting execution times
-   `Dockerfile`: Container build file
-   `Makefile`: Top-level build file
-   `README`: This file

---

# 4. Contributing

Feel free to open issues or submit pull requests for improvements or bug fixes.

---

# 5. Meta
gcsar

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="https://github.com/thisisnotgcsar/ODC_23-24-CTFs">Skyline</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://github.com/thisisnotgcsar">gcsar</a> is licensed under <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-SA 4.0<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1"></a></p>

https://github.com/thisisnotgcsar


