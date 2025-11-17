/**
 * omp-skyline.c
 * --------------
 * Computes the skyline of a set of multi-dimensional points using OpenMP for parallelization.
 * Uses shared utilities for reading, printing, and freeing points.
 */

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "../common/skyline_utils.h"

/**
 * Compute the skyline of |points|. At the end, s[i] == 1 iff point
 * |i| belongs to the skyline. This function returns the number r of
 * points in the skyline. The caller is responsible for allocating
 * a suitably sized array |s|.
 */
int omp_skyline(const points_t *points, int *s)
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, j, r = N;

    /* Initially, assume all points are in the skyline */
    for (i = 0; i < N; i++)
    {
        s[i] = 1;
    }

    /* For each point, check if it dominates any other point */
    for (i = 0; i < N; i++)
    {
        if (s[i])
        {
            /* Parallelize inner loop using OpenMP */
            #pragma omp parallel for reduction(+:r) default(none) shared(i, s, P) firstprivate(N, D)
            for (j = 0; j < N; j++)
            {
                if (s[j] && dominates(&(P[i * D]), &(P[j * D]), D))
                {
                    s[j] = 0; /* Remove dominated point from skyline */
                    r--;
                }
            }
        }
    }
    return r;
}

int main(int argc, char *argv[])
{
    points_t points;

    /* Check for correct usage */
    if (argc != 1)
    {
        fprintf(stderr, "Usage: %s < input_file > output_file\n", argv[0]);
        return EXIT_FAILURE;
    }

    /* Read input points */
    read_input(&points);

    /* Allocate array to mark skyline points */
    int *s = (int *)malloc(points.N * sizeof(*s));
    assert(s);

    /* Compute skyline */
    const int r = omp_skyline(&points, s);

    /* Print skyline points */
    print_skyline(&points, s, r);

    /* Free memory */
    free_points(&points);
    free(s);
    return EXIT_SUCCESS;
}
