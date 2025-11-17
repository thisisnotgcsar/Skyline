/**
 * mpi-skyline.c
 * -------------
 * Computes the skyline of a set of multi-dimensional points using MPI for parallelization.
 * Uses shared utilities for reading, printing, and freeing points.
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "../common/skyline_utils.h"
#include <mpi.h>

/**
 * Compute the skyline of |points|. At the end, s[i] == 1 iff point
 * |i| belongs to the skyline. This function returns the number r of
 * points in to the skyline. The caller is responsible for allocating
 * a suitably sized array |s|.
 */
void mpi_skyline( const points_t *points, int* s, int start, int end) {
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
    mpi_skyline(&points, s, start, end);
    MPI_Reduce(s, result, N, MPI_INT, MPI_PROD, 0, MPI_COMM_WORLD);
    if(rank == 0){
        r = count_dominants(result, N);
    	print_skyline(&points, result, r);
    	free(result);
    }
    free_points(&points);
    free(s);
    MPI_Finalize();
    return EXIT_SUCCESS;
}
