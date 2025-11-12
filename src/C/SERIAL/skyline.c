/****************************************************************************
 *
 * skyline.c
 *
 * Serial implementation of the skyline operator
 *
 * --------------------------------------------------------------------------
 *
 * This program computes the skyline of a set of points in D dimensions
 * read from standard input.
 *
 * Compile with:
 * gcc -D_XOPEN_SOURCE=600 -std=c99 -Wall -Wpedantic -O2 skyline.c -o skyline
 *
 * Run with:
 * ./skyline < input > output
 *
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef struct {
    float *P;   // Coordinates P[i][j] of point i
    int N;      // Number of points
    int D;      // Number of dimensions
} points_t;

/**
 * Read input from stdin. Input format:
 * D [ignored]
 * N
 * p0,0 p0,1 ... p0,D-1
 * p1,0 p1,1 ... p1,D-1
 * ...
 * pN-1,0 pN-1,1 ... pN-1,D-1
 */
void read_input( points_t *points )
{
    char buf[1024];
    int N, D, i, k;
    float *P;

    if (1 != scanf("%d", &D)) {
        fprintf(stderr, "FATAL: can not read the dimension\n");
        exit(EXIT_FAILURE);
    }
    assert(D >= 2);
    if (NULL == fgets(buf, sizeof(buf), stdin)) { // ignore rest of the line
        fprintf(stderr, "FATAL: can not read the first line\n");
        exit(EXIT_FAILURE);
    }
    if (1 != scanf("%d", &N)) {
        fprintf(stderr, "FATAL: can not read the number of points\n");
        exit(EXIT_FAILURE);
    }
    P = (float*)malloc( D * N * sizeof(*P) );
    assert(P);
    for (i=0; i<N; i++) {
        for (k=0; k<D; k++) {
            if (1 != scanf("%f", &(P[i*D + k]))) {
                fprintf(stderr, "FATAL: failed to get coordinate %d of point %d\n", k, i);
                exit(EXIT_FAILURE);
            }
        }
    }
    points->P = P;
    points->N = N;
    points->D = D;
}

/**
 * Free memory used by points
 */
void free_points( points_t* points )
{
    free(points->P);
    points->P = NULL;
    points->N = points->D = -1;
}

/**
 * Returns 1 if p dominates q, 0 otherwise
 */
int dominates( const float * p, const float * q, int D )
{
    int k;
    int dominated = 0;

    /* The following loop could be merged, but kept separate for readability */
    for (k=0; k<D; k++) {
        if (p[k] < q[k]) {
            return 0;
        }
        if (p[k] > q[k]) {
            dominated = 1;
        }
    }
    return dominated;
}

/**
 * Compute the skyline of points. At the end, s[i] == 1 if point i is in the skyline.
 * Returns the number of skyline points. Caller must allocate s.
 */
int skyline( const points_t *points, int *s )
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, j, r = N;

    for (i=0; i<N; i++) {
        s[i] = 1;
    }

    for (i=0; i<N; i++) {
        if ( s[i] ) {
            for (j=0; j<N; j++) {
                if ( s[j] && dominates( &(P[i*D]), &(P[j*D]), D ) ) {
                    s[j] = 0;
                    r--;
                }
            }
        }
    }
    return r;
}

/**
 * Print the coordinates of skyline points to stdout.
 * Output format matches input format.
 */
void print_skyline( const points_t* points, const int *s, int r )
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, k;

    printf("%d\n", D);
    printf("%d\n", r);
    for (i=0; i<N; i++) {
        if ( s[i] ) {
            for (k=0; k<D; k++) {
                printf("%f ", P[i*D + k]);
            }
            printf("\n");
        }
    }
}

int main( int argc, char* argv[] )
{
    points_t points;

    if (argc != 1) {
        fprintf(stderr, "Usage: %s < input_file > output_file\n", argv[0]);
        return EXIT_FAILURE;
    }

    read_input(&points);
    int *s = (int*)malloc(points.N * sizeof(*s));
    assert(s);
    skyline(&points, s);
    free_points(&points);
    free(s);
    return EXIT_SUCCESS;
}
