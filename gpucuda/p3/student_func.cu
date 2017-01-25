/* Udacity Homework 3
 HDR Tone-mapping

 Background HDR
 ==============

 A High Dynamic Range (HDR) image contains a wider variation of intensity
 and color than is allowed by the RGB format with 1 byte per channel that we
 have used in the previous assignment.

 To store this extra information we use single precision floating point for
 each channel.  This allows for an extremely wide range of intensity values.

 In the image for this assignment, the inside of church with light coming in
 through stained glass windows, the raw input floating point values for the
 channels range from 0 to 275.  But the mean is .41 and 98% of the values are
 less than 3!  This means that certain areas (the windows) are extremely bright
 compared to everywhere else.  If we linearly map this [0-275] range into the
 [0-255] range that we have been using then most values will be mapped to zero!
 The only thing we will be able to see are the very brightest areas - the
 windows - everything else will appear pitch black.

 The problem is that although we have cameras capable of recording the wide
 range of intensity that exists in the real world our monitors are not capable
 of displaying them.  Our eyes are also quite capable of observing a much wider
 range of intensities than our image formats / monitors are capable of
 displaying.

 Tone-mapping is a process that transforms the intensities in the image so that
 the brightest values aren't nearly so far away from the mean.  That way when
 we transform the values into [0-255] we can actually see the entire image.
 There are many ways to perform this process and it is as much an art as a
 science - there is no single "right" answer.  In this homework we will
 implement one possible technique.

 Background Chrominance-Luminance
 ================================

 The RGB space that we have been using to represent images can be thought of as
 one possible set of axes spanning a three dimensional space of color.  We
 sometimes choose other axes to represent this space because they make certain
 operations more convenient.

 Another possible way of representing a color image is to separate the color
 information (chromaticity) from the brightness information.  There are
 multiple different methods for doing this - a common one during the analog
 television days was known as Chrominance-Luminance or YUV.

 We choose to represent the image in this way so that we can remap only the
 intensity channel and then recombine the new intensity values with the color
 information to form the final image.

 Old TV signals used to be transmitted in this way so that black & white
 televisions could display the luminance channel while color televisions would
 display all three of the channels.


 Tone-mapping
 ============

 In this assignment we are going to transform the luminance channel (actually
 the log of the luminance, but this is unimportant for the parts of the
 algorithm that you will be implementing) by compressing its range to [0, 1].
 To do this we need the cumulative distribution of the luminance values.

 Example
 -------

 input : [2 4 3 3 1 7 4 5 7 0 9 4 3 2]
 min / max / range: 0 / 9 / 9

 histo with 3 bins: [4 7 3]

 cdf : [4 11 14]


 Your task is to calculate this cumulative distribution by following these
 steps.

 */

#include "utils.h"
#include <stdio.h>

/*
 a has length n
 reduce is computed in place per blocks
 so that a[blockIdx.x * blockDim.x] contains the minimum element of the block with indices
 (blockIdx.x * blockDim.x,blockIdx.x * blockDim.x)
 of the vector a
 */
__global__
void reduce_min_kernel(float* a, int n, bool isMin) {

    int block_offset = blockIdx.x * blockDim.x;
    int id = threadIdx.x;
    int offset = id + block_offset;
    // divide input in blocks: 0...elements_per_block-1,,elements_per_block..elements_per_block*2-1, elements_per_block*k..n
    int elements_in_extra_block = n % blockDim.x;
    int active_blocks = n / blockDim.x + (elements_in_extra_block != 0);
    int block_n; // elements per block
    if (blockIdx.x == active_blocks && elements_in_extra_block != 0) {
        block_n = elements_in_extra_block; // the last block does less work if n is not divisible by number of threads in block
    } else {
        block_n = blockDim.x;
    }
    int h = block_n / 2;

    while (id < h) {
//		if (id == 0) {
//			float m = a[0];
//			for (int i = 1; i < n; i++) {
//				m = max(m, a[i]);
//			}
//			printf("max=%d", m);
//		}
        //__syncthreads();

        // comparte two elements and put the min/max i
        if (isMin) {
            a[offset] = min(a[offset + h], a[offset]);
        } else {
            a[offset] = max(a[offset + h], a[offset]);
        }
        // if the block_current n is not divisible by 2, the first thread of the block updates with the last element
        if ((id == 0) && (block_n % 2 == 1)) {
            if (isMin) {
                a[block_offset] = min(a[block_offset], a[block_offset + block_n - 1]);
            } else {
                a[block_offset] = max(a[block_offset], a[block_offset + block_n - 1]);
            }
        }
        block_n = h;
        h /= 2;
        __syncthreads();
    }

}

__global__
void reduce_min_kernel_blocks(float* a, int n, bool isMin) {

    int elements_in_extra_block = n % blockDim.x;
    int active_blocks = n / blockDim.x + (elements_in_extra_block != 0);

    for (int i = 1; i < active_blocks; i++) {
        if (isMin) {
            a[0] = min(a[i * blockDim.x], a[0]);
        } else {
            a[0] = max(a[i * blockDim.x], a[0]);
        }

    }
}

const int elements_per_thread = 1;

// assumes n<= maximum_block_size*maximum_block_number
float reduce_min(const float* const d_a, int n, bool isMin) {
    const int BS = 1024;
    const dim3 blockSize(BS, 1, 1);

    const int elements_per_block = elements_per_thread * BS;
    int blocks = n / elements_per_block / 2;
    if (blocks * elements_per_block * 2 < n) {
        //printf("increase %d \n",blocks * elements_per_block );
        blocks++;
    }
    //printf("%d elements, %d blocks, %d elements_per_block\n", n, blocks,elements_per_block);

    const dim3 gridSize(blocks, 1, 1);
    float * d_min;
    cudaDeviceSynchronize();
    checkCudaErrors(cudaMalloc(&d_min, sizeof(float) * n));
    cudaDeviceSynchronize();
    checkCudaErrors(cudaMemcpy(d_min, d_a, sizeof(float) * n, cudaMemcpyDeviceToDevice));
    reduce_min_kernel<<<gridSize, blockSize>>>(d_min, n, isMin);

    reduce_min_kernel_blocks<<<1, 1>>>(d_min, n, isMin);

    float result;
    checkCudaErrors(cudaMemcpy(&result, d_min, sizeof(float), cudaMemcpyDeviceToHost));

    checkCudaErrors(cudaFree(d_min));
    return result;
}

__global__
void histogram_kernel(unsigned int* d_hist, int bins, const float* d_logLuminance, int n, float min_logLum,
        float max_logLum, float lumRange) {

    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i >= n) {
        return;
    }
    int bin = (d_logLuminance[i] - min_logLum) / lumRange * bins;
    atomicAdd(&(d_hist[bin]), 1);
}

// assumes n<= maximum_block_size*maximum_block_number
void histogram(unsigned int* d_hist, int bins, const float* d_logLuminance, int n, float min_logLum, float max_logLum,
        float lumRange) {
    const int BS = 1024;
    const dim3 block_size(BS, 1, 1);
    const int blocks = (int) n / BS + (n % BS != 0);
    const dim3 grid_size(blocks, 1, 1);

    histogram_kernel<<<grid_size,block_size>>>(d_hist, bins, d_logLuminance, n, min_logLum, max_logLum, lumRange);
}
__global__
void blelloch_scan_sum_inplace_kernel_phase1(unsigned int* a, int n) {
    // 01 23 45 67
    //  1  3  5  7
    //     3     7
    //           7

    // index to update
    int update = threadIdx.x * 2 + 1; // because we are spawning n/2 threads

    // index to look for
    int displacement = 1;
    int look_for = update - displacement;
    int iterations = update;
    while (iterations % 2 == 1) {
//        printf("%d <- %d || %u <- %u \n",update,look_for,a[update],a[look_for]);
        a[update] += a[look_for];
        displacement *= 2;
        look_for = update - displacement;
        iterations /= 2;
        __syncthreads();
    }
    if (update ==n-1){
        a[update]=0;
    }


}

__global__
void blelloch_scan_sum_inplace_kernel_phase2(unsigned int* a, int n) {




    //               7
    //       3       7
    //   1   3   5   7
    // 0 1 2 3 4 5 6 7

    // 7: 3, 5, 6
    // 5: _, _, 4
    // 3: _, 1, 2
    // 1: _, _, 0

    //                                    15
    //               7                    15
    //       3       7        11          15
    //   1   3   5   7   9    11    13    15
    // 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15

    //     n (size of sub arrays)
    //     16  8   4   2
    //     displacements
    //     8   4   2   1
    //     look fors (! or _ means not used)
    //15:  7  11  13  14
    //13:  5!  9! 11! 12
    //11:  3!  7!  9  10
    // 9:  1!  5!  7!  8
    // 7:  _   3   5   6
    // 5:  _   _   _   4
    // 3:  _   _   1   2
    // 1:  _   _   _   0

    // index to update
    int update = threadIdx.x * 2 + 1; // because we are spawning n/2 threads


    int displacement = n/2;

    while (n>1) {
        if ( (update+1)% n == 0){
            // index to look for
            int look_for = update - displacement;
//            printf("%d <- %d || %u <- %u \n",update,look_for,a[update],a[look_for]);

            // downsweep op
            int t =a[look_for];
            a[look_for]=a[update];
            a[update] += t;


        }

        n=displacement;
        displacement /= 2;
        __syncthreads();
    }


}

void blelloch_scan_sum_inplace(unsigned int* d_a, int n) {

    const int BS = 1024;
    //n=32;
    const int threads_needed=n/2;

    if (threads_needed > BS ) {
        printf("\n  histogram length: %d\n", n);
        printf("ERROR: current version of scan can only be implemented in 1 block with %d threads!",BS);
        exit(0);
    }
    const dim3 block_size(threads_needed, 1, 1);
    const dim3 grid_size(1, 1, 1);


    blelloch_scan_sum_inplace_kernel_phase1<<< grid_size,block_size>>>(d_a, n);

    //cudaDeviceSynchronize();

//    printf("middle\n");


//      unsigned int* h_a = new unsigned int[n];
//    checkCudaErrors(cudaMemcpy(h_a , d_a, sizeof(unsigned int) * n, cudaMemcpyDeviceToHost));
//    for (int i = 0; i < n; i++) {
//        printf("%d,", h_a[i]);
//    }
//    printf("\n");

    cudaDeviceSynchronize();
    blelloch_scan_sum_inplace_kernel_phase2<<<grid_size,block_size>>>(d_a, n);


//    unsigned int* h_a = new unsigned int[n];
//    checkCudaErrors(cudaMemcpy(h_a , d_a, sizeof(unsigned int) * n, cudaMemcpyDeviceToHost));
//
//    for (int i = 0; i < n; i++) {
//        printf("%d,", h_a[i]);
//    }
//    printf("\n");

}


void your_histogram_and_prefixsum(const float* const d_logLuminance, unsigned int* const d_cdf, float &min_logLum,
        float &max_logLum, const size_t numRows, const size_t numCols, const size_t numBins) {
    //TODO
    /*Here are the steps you need to implement
     1) find the minimum and maximum value in the input logLuminance channel
     store in min_logLum and max_logLum
     2) subtract them to find the range
     3) generate a histogram of all the values in the logLuminance channel using
     the formula: bin = (lum[i] - lumMin) / lumRange * numBins
     4) Perform an exclusive scan (prefix sum) on the histogram to get
     the cumulative distribution of luminance values (this should go in the
     incoming d_cdf pointer which already has been allocated for you)       */

//	int *d_hist;
//	checkCudaErrors(cudaMalloc(&d_hist, sizeof(int) * numBins));
    int n = numRows * numCols;
    min_logLum = reduce_min(d_logLuminance, n, true);
    max_logLum = reduce_min(d_logLuminance, n, false);

    float lumRange = max_logLum - min_logLum;
    histogram(d_cdf, numBins, d_logLuminance, n, min_logLum, max_logLum, lumRange);
    blelloch_scan_sum_inplace(d_cdf, numBins);

}
