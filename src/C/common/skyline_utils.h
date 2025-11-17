/**
 * skyline_utils.h
 * ---------------
 * Shared utilities for Skyline algorithms.
 * Provides functions and types for reading points, freeing memory,
 * dominance checking, and printing skyline results.
 * Used by serial, OpenMP, and MPI implementations.
 */

#ifndef SKYLINE_UTILS_H
#define SKYLINE_UTILS_H

/* Structure to hold points and their dimensions */
typedef struct
{
    float *P; /* coordinates P[i][j] of point i */
    int N;    /* Number of points */
    int D;    /* Number of dimensions */
} points_t;

/* Read points from stdin */
void read_input(points_t *points);

/* Free memory allocated for points */
void free_points(points_t *points);

/* Returns 1 iff |p| dominates |q| */
int dominates(const float *p, const float *q, int D);

/* Print the coordinates of points belonging to the skyline */
void print_skyline(const points_t *points, const int *s, int r);

#endif // SKYLINE_UTILS_H
