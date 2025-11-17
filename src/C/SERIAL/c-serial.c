/**
 * c-skyline.c
 * -----------
 * Computes the skyline of a set of multi-dimensional points (serial version).
 * Uses shared utilities for reading, printing, and freeing points.
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "../common/skyline_utils.h"

/* Serial skyline computation */
int skyline(const points_t *points, int *s)
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, j, r = N;

    for (i = 0; i < N; i++)
    {
        s[i] = 1;
    }

    for (i = 0; i < N; i++)
    {
        if (s[i])
        {
            for (j = 0; j < N; j++)
            {
                if (s[j] && dominates(&(P[i * D]), &(P[j * D]), D))
                {
                    s[j] = 0;
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

    // argc == 1 means no extra arguments (just program name)
    if (argc != 1)
    {
        fprintf(stderr, "Usage: %s < input_file > output_file\n", argv[0]);
        return EXIT_FAILURE;
    }

    read_input(&points);
    int *s = (int *)malloc(points.N * sizeof(*s));
    assert(s);
    const int r = skyline(&points, s);
    print_skyline(&points, s, r);

    free_points(&points);
    free(s);
    return EXIT_SUCCESS;
}
