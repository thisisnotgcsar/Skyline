/**
 * cuda-skyline.cu
 * ---------------
 * Computes the skyline of a set of multi-dimensional points using CUDA for GPU parallelization.
 * 
 * Each point is assigned to a thread block, and threads within a block check
 * for dominance relationships in parallel. The algorithm uses a two-phase approach:
 * 1. Transfer point data from host (CPU) to device (GPU) memory
 * 2. Execute parallel dominance checking on the GPU where each thread block processes one point
 * 3. Transfer results back to host memory
 * 
 * The dominance checking is parallelized such that each thread checks if the point assigned
 * to its block dominates a subset of all other points. Results are synchronized using atomic
 * operations to maintain consistency.
 * 
 * Uses shared utilities for reading, printing, and freeing points.
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <cuda_runtime.h>
#include "../common/skyline_utils.h"

/* CUDA error checking macro */
#define CUDA_CHECK(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            fprintf(stderr, "CUDA error at %s:%d: %s\n", __FILE__, __LINE__, \
                    cudaGetErrorString(err)); \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

/**
 * CUDA kernel: Check dominance relationships for points
 * 
 * Each block processes one point (blockIdx.x corresponds to point i).
 * Each thread within the block checks if point i dominates a subset of other points.
 * 
 * @param P         Flattened array of all points in device memory (N * D elements)
 * @param s         Array marking skyline membership (1 = in skyline, 0 = dominated)
 * @param N         Total number of points
 * @param D         Number of dimensions per point
 */
__global__ void cuda_dominance_kernel(const float *P, int *s, int N, int D)
{
    /* Point index that this block is responsible for checking */
    int i = blockIdx.x;
    
    /* Point index to check against (distributed across threads) */
    int j = blockIdx.y * blockDim.x + threadIdx.x;
    
    /* Early exit if this thread's point index is out of bounds */
    if (j >= N) return;
    
    /* Skip if point i is already eliminated from skyline */
    if (s[i] == 0) return;
    
    /* Skip self-comparison */
    if (i == j) return;
    
    /* Check if point i dominates point j */
    int dominates_flag = 1;  /* Assume p[i] dominates p[j] */
    int strictly_better = 0;  /* Track if p[i] is strictly better in at least one dimension */
    
    /* Load coordinates for points i and j, then check dominance */
    for (int k = 0; k < D; k++)
    {
        float pi_k = P[i * D + k];
        float pj_k = P[j * D + k];
        
        /* If p[i] is worse than p[j] in any dimension, it doesn't dominate */
        if (pi_k < pj_k)
        {
            dominates_flag = 0;
            break;
        }
        
        /* Track if p[i] is strictly better in at least one dimension */
        if (pi_k > pj_k)
        {
            strictly_better = 1;
        }
    }
    
    /* Point i dominates point j only if it's not worse in any dimension
     * AND strictly better in at least one dimension */
    if (dominates_flag && strictly_better && s[j] == 1)
    {
        /* Mark point j as dominated (removed from skyline) using atomic operation */
        atomicExch(&s[j], 0);
    }
}

/**
 * Compute the skyline of |points| using CUDA GPU acceleration.
 * 
 * At the end, s[i] == 1 iff point i belongs to the skyline.
 * This function returns the number r of points in the skyline.
 * The caller is responsible for allocating a suitably sized array |s|.
 * 
 * @param points    Structure containing all points and metadata
 * @param s         Output array marking skyline membership (host memory)
 * @return          Number of points in the skyline
 */
int cuda_skyline(const points_t *points, int *s)
{
    const int D = points->D;
    const int N = points->N;
    const float *P = points->P;
    
    /* Device pointers for GPU memory */
    float *d_P = NULL;
    int *d_s = NULL;
    
    /* Initially, assume all points are in the skyline */
    for (int i = 0; i < N; i++)
    {
        s[i] = 1;
    }
    
    /* Allocate device memory for points and skyline markers */
    CUDA_CHECK(cudaMalloc(&d_P, N * D * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_s, N * sizeof(int)));
    
    /* Copy data from host to device */
    CUDA_CHECK(cudaMemcpy(d_P, P, N * D * sizeof(float), cudaMemcpyHostToDevice)); // TODO use constant memory
    CUDA_CHECK(cudaMemcpy(d_s, s, N * sizeof(int), cudaMemcpyHostToDevice));
    
    /* Configure CUDA kernel launch parameters */
    /* Use 2D grid: each block along x-axis handles one point i */
    /* Blocks along y-axis and threads distribute the checking of all points j */
    int threads_per_block = 256;  /* Standard block size for good occupancy */
    int blocks_y = (N + threads_per_block - 1) / threads_per_block; // for each point I have to do N checks
    
    dim3 grid_dim(N, blocks_y);  /* N blocks for N points to check, blocks_y for j distribution */
    dim3 block_dim(threads_per_block);
    
    /* Launch the kernel */
    cuda_dominance_kernel<<<grid_dim, block_dim>>>(d_P, d_s, N, D);
    
    /* Check for kernel launch errors */
    CUDA_CHECK(cudaGetLastError());
    
    /* Wait for kernel to complete */
    CUDA_CHECK(cudaDeviceSynchronize());
    
    /* Copy results back from device to host */
    CUDA_CHECK(cudaMemcpy(s, d_s, N * sizeof(int), cudaMemcpyDeviceToHost));
    
    /* Free device memory */
    CUDA_CHECK(cudaFree(d_P));
    CUDA_CHECK(cudaFree(d_s));
    
    /* Count the number of points in the skyline */
    int r = 0;
    for (int i = 0; i < N; i++)
    {
        if (s[i])
        {
            r++;
        }
    }
    
    return r;
}

/**
 * Main function: Read input, compute skyline using CUDA, and print results.
 */
int main(int argc, char *argv[])
{
    points_t points;
    
    /* Check for correct usage */
    if (argc != 1)
    {
        fprintf(stderr, "Usage: %s < input_file > output_file\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    /* Read input points from stdin */
    read_input(&points);
    
    /* Allocate array to mark skyline points */
    int *s = (int *)malloc(points.N * sizeof(*s));
    assert(s);
    
    /* Compute skyline using CUDA */
    const int r = cuda_skyline(&points, s);
    
    /* Print skyline points to stdout */
    print_skyline(&points, s, r);
    
    /* Free memory */
    free_points(&points);
    free(s);
    
    return EXIT_SUCCESS;
}
