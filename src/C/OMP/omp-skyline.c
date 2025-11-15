/*
 * Giulio Golinelli
 * 0000883007
 * 17/02/2021
 * High Performance Computing
 *
 * OMP Skyline
*/

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef struct
{
    float *P; /* coordinates P[i][j] of point i               */
    int N;    /* Number of points (rows of matrix P)          */
    int D;    /* Number of dimensions (columns of matrix P)   */
} points_t;

/**
 * Read input from stdin. Input format is:
 *
 * d [other ignored stuff]
 * N
 * p0,0 p0,1 ... p0,d-1
 * p1,0 p1,1 ... p1,d-1
 * ...
 * pn-1,0 pn-1,1 ... pn-1,d-1
 *
 */
void read_input(points_t *points)
{
    char buf[1024];
    int N, D, i, k;
    float *P;

    if (1 != scanf("%d", &D))
    {
        fprintf(stderr, "FATAL: can not read the dimension\n");
        exit(EXIT_FAILURE);
    }
    assert(D >= 2);
    if (NULL == fgets(buf, sizeof(buf), stdin))
    { /* ignore rest of the line */
        fprintf(stderr, "FATAL: can not read the first line\n");
        exit(EXIT_FAILURE);
    }
    if (1 != scanf("%d", &N))
    {
        fprintf(stderr, "FATAL: can not read the number of points\n");
        exit(EXIT_FAILURE);
    }
    P = (float *)malloc(D * N * sizeof(*P));
    assert(P);
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

    /* The following loop could be merged, but the keep them separated
       for the sake of readability */
    for (k = 0; k < D; k++)
    {
        if (p[k] < q[k])
        {
            return 0;
        }
    }
    for (k = 0; k < D; k++)
    {
        if (p[k] > q[k])
        {
            return 1;
        }
    }
    return 0;
}

/**
 * Compute the skyline of |points|. At the end, s[i] == 1 iff point
 * |i| belongs to the skyline. This function returns the number r of
 * points in to the skyline. The caller is responsible for allocating
 * a suitably sized array |s|.
 */
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
            #pragma omp parallel for reduction(+:r) default(none) shared(i, s, P) firstprivate(N, D)
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

/**
 * Print the coordinates of points belonging to the skyline |s| to
 * standard ouptut. s[i] == 1 iff point i belongs to the skyline.  The
 * output format is the same as the input format, so that this program
 * can process its own output.
 */
void print_skyline(const points_t *points, const int *s, int r)
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, k;

    printf("%d\n", D);
    printf("%d\n", r);
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

int main(int argc, char *argv[])
{
    points_t points;

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
