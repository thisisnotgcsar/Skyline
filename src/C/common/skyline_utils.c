/**
 * skyline_utils.c
 * ---------------
 * Implements shared utilities for Skyline algorithms.
 * Contains functions for reading points, freeing memory,
 * dominance checking, and printing skyline results.
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "skyline_utils.h"

/**
 * Read input from stdin. Input format is:
 * d [other ignored stuff]
 * N
 * p0,0 p0,1 ... p0,d-1
 * p1,0 p1,1 ... p1,d-1
 * ...
 * pn-1,0 pn-1,1 ... pn-1,d-1
 */
void read_input(points_t *points)
{
    char buf[1024];
    int N, D, i, k;
    float *P;

    /* Read dimension */
    if (1 != scanf("%d", &D))
    {
        fprintf(stderr, "FATAL: can not read the dimension\n");
        exit(EXIT_FAILURE);
    }
    assert(D >= 2);

    /* Ignore rest of the line */
    if (NULL == fgets(buf, sizeof(buf), stdin))
    {
        fprintf(stderr, "FATAL: can not read the first line\n");
        exit(EXIT_FAILURE);
    }

    /* Read number of points */
    if (1 != scanf("%d", &N))
    {
        fprintf(stderr, "FATAL: can not read the number of points\n");
        exit(EXIT_FAILURE);
    }

    /* Allocate memory for points */
    P = (float *)malloc(D * N * sizeof(*P));
    assert(P);

    /* Read coordinates for each point */
    for (i = 0; i < N; i++)
    {
        for (k = 0; k < D; k++)
        {
            if (1 != scanf("%f", &(P[i * D + k])))
            {
                fprintf(stderr, "FATAL: failed to get coordinate %d of point %d\n", k, i);
                exit(EXIT_FAILURE);
            }
        }
    }
    points->P = P;
    points->N = N;
    points->D = D;
}

/* Free memory allocated for points */
void free_points(points_t *points)
{
    free(points->P);
    points->P = NULL;
    points->N = points->D = -1;
}

/* Returns 1 iff |p| dominates |q| */
int dominates(const float *p, const float *q, int D)
{
    int k;
    int strictly_better = 0;
    for (k = 0; k < D; k++)
    {
        if (p[k] < q[k])
        {
            return 0;
        }
        if (p[k] > q[k])
        {
            strictly_better = 1;
        }
    }
    return strictly_better;
}

/**
 * Print the coordinates of points belonging to the skyline |s| to
 * standard output. s[i] == 1 iff point i belongs to the skyline.
 * Output format is the same as input format.
 */
void print_skyline(const points_t *points, const int *s, int r)
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, k;

    /* Print dimension and number of skyline points */
    printf("%d\n", D);
    printf("%d\n", r);

    /* Print coordinates of each skyline point */
    for (i = 0; i < N; i++)
    {
        if (s[i])
        {
            for (k = 0; k < D; k++)
            {
                printf("%f ", P[i * D + k]);
            }
            printf("\n");
        }
    }
}
