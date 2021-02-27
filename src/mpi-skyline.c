/*	
 * Giulio Golinelli
 * 0000883007
 * 17/02/2021
 * High Performance Computing
 *
 * MPI Skyline 
*/ 

#include "hpc.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <mpi.h>

typedef struct {
    float *P;   /* coordinates P[i][j] of point i               */
    int N;      /* Number of points (rows of matrix P)          */
    int D;      /* Number of dimensions (columns of matrix P)   */
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
    if (NULL == fgets(buf, sizeof(buf), stdin)) { /* ignore rest of the line */
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

void free_points( points_t* points )
{
    free(points->P);
    points->P = NULL;
    points->N = points->D = -1;
}

/* Returns 1 iff |p| dominates |q| */
int dominates( const float * p, const float * q, int D )
{
    int k;

    /* The following loop could be merged, but the keep them separated
       for the sake of readability */
    for (k=0; k<D; k++) {
        if (p[k] < q[k]) {
            return 0;
        }
    }
    for (k=0; k<D; k++) {
        if (p[k] > q[k]) {
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
void skyline( const points_t *points, int* s, int start, int end) {
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    int i, j;

    for(i=0; i<N; i++)
	  s[i] = 1;

    for (i=start; i<end; i++)
        if ( s[i] )
            for (j=0; j<N; j++)
                if (s[j] && dominates(&(P[i*D]), &(P[j*D]), D))
                    s[j] = 0;
}

/**
 * Print the coordinates of points belonging to the skyline |s| to
 * standard ouptut. s[i] == 1 iff point i belongs to the skyline.  The
 * output format is the same as the input format, so that this program
 * can process its own output.
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

int count_dominants(int* s, int size){
    int i, c = 0;
    for(i=0; i<size; i++)
        if(s[i])
            c++;                
    return c;
}

int main( int argc, char* argv[] )
{
    points_t points;
    int rank, size;
    int N, start, end, r;     
    int* s;
    int* result = NULL;

    MPI_Init (&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size); 
    
    if (rank == 0 && argc != 1) {
        fprintf(stderr, "Usage: %s < input_file > output_file\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    //master process reads file and broadcast points
    if(rank == 0)
    	read_input(&points);
    MPI_Bcast(&(points.N), 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&(points.D), 1, MPI_INT, 0, MPI_COMM_WORLD);
    if (rank != 0){
    	points.P = (float*) malloc(points.N * points.D * sizeof(float));
    	assert(points.P);
    }
    MPI_Bcast(points.P, points.N * points.D, MPI_FLOAT, 0, MPI_COMM_WORLD);
    
    N = points.N;
    
    start = rank * N/size;
    end = (rank + 1) * N/size;
    
    if (rank == size-1)
    	end += N%size; //the last process does the rest
    if (rank == 0)
	result = (int*) malloc(N * sizeof(int)); //master process allocates memory for the result
    s = (int*) malloc(N * sizeof(int)); 
    const double tstart = hpc_gettime();
    skyline(&points, s, start, end);
    MPI_Reduce(s, result, N, MPI_INT, MPI_PROD, 0, MPI_COMM_WORLD);
    const double elapsed = hpc_gettime() - tstart;
    if(rank == 0){
        r = count_dominants(result, N);
    	print_skyline(&points, result, r);
    	free(result);
    	fprintf(stderr, "\n\t%d points\n\t%d dimensione\n\t%d points in skyline\n\nExecution time %f seconds\n", points.N, points.D, r, elapsed);
    }
    free_points(&points);
    free(s);
    MPI_Finalize();
    return EXIT_SUCCESS;
}
