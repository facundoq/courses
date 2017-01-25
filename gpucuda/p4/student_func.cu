//Udacity HW 4
//Radix Sorting

#include "utils.h"
#include <thrust/host_vector.h>

/* Red Eye Removal
 ===============

 For this assignment we are implementing red eye removal.  This is
 accomplished by first creating a score for every pixel that tells us how
 likely it is to be a red eye pixel.  We have already done this for you - you
 are receiving the scores and need to sort them in ascending order so that we
 know which pixels to alter to remove the red eye.

 Note: ascending order == smallest to largest

 Each score is associated with a position, when you sort the scores, you must
 also move the positions accordingly.

 Implementing Parallel Radix Sort with CUDA
 ==========================================

 The basic idea is to construct a histogram on each pass of how many of each
 "digit" there are.   Then we scan this histogram so that we know where to put
 the output of each digit.  For example, the first 1 must come after all the
 0s so we have to know how many 0s there are to be able to start moving 1s
 into the correct position.

 1) Histogram of the number of occurrences of each digit
 2) Exclusive Prefix Sum of Histogram
 3) Determine relative offset of each digit
 For example [0 0 1 1 0 0 1]
 ->  [0 1 0 1 2 3 2]
 4) Combine the resluts of steps 2 & 3 to determine the final
 output location for each element and move it there

 LSB Radix sort is an out-of-place sort and you will need to ping-pong values
 between the input and output buffers we have provided.  Make sure the final
 sorted resluts end up in the output buffer!  Hint: You may need to do a copy
 at the end.

 */

/*
 *
 * Each block computes a different histogram. Histograms are merged afterwards.
 * Each block gets a portion of the input elements
 */
typedef unsigned long long int luint ;
__global__
void count_match_bitmask_kernel(unsigned int* const d_a, const size_t n, unsigned int bit_mask,
        luint* const d_count) {
    __shared__ luint block_count[1];

    if (threadIdx.x == 0) {
        block_count[0] = 0;
    }
    __syncthreads();

    luint total_threads = blockDim.x * gridDim.x;
    luint elements_per_thread = n / total_threads + ((n % total_threads) > 0);
    luint global_idx = (luint ) blockDim.x * (luint ) blockIdx.x
            + (luint) threadIdx.x;
    luint start = global_idx * elements_per_thread;

    if (start >= n) {
        //printf("t,b=%d,%d no work\n",blockIdx.x, threadIdx.x);
        return;
    }

    luint end = min((luint) n, start + elements_per_thread);
    luint count = 0;
    for (; start < end; start++) {
        if (d_a[start] & bit_mask) {
            count++;
        }
    }
    __syncthreads();
    atomicAdd(block_count, count);


    __syncthreads();
    if (threadIdx.x == 0) {
        //printf("block=%u,thread=%u,block_count=%llu,count=%llu, start=%llu, end=%llu, global_idx=%llu,el_per_thread=%llu,d_count=%llu\n",
          //      blockIdx.x, threadIdx.x, block_count[0], count, global_idx * elements_per_thread, end, global_idx,
            //    elements_per_thread,d_count[0]);
        atomicAdd(d_count, block_count[0]);
    }
}

const size_t count_max_threads_per_block = 1024;
const size_t max_blocks = 16;

/*
 * Computes the binary histogram of the entries in
 */
void count_match_bitmask(unsigned int* const d_a, const size_t n, luint* d_count, unsigned int bit_mask) {
    checkCudaErrors(cudaMemset(d_count, 0, sizeof(luint) * 1));


    int threads = min(n, count_max_threads_per_block);
    size_t blocks_required_with_one_element_per_thread = n / threads + ((n % threads) > 0);
    int blocks = min(blocks_required_with_one_element_per_thread, max_blocks);
    const dim3 blockSize(threads);
    const dim3 gridSize(blocks);

    count_match_bitmask_kernel<<<gridSize, blockSize, 1>>>(d_a, n, bit_mask, d_count);
}

__global__
void copy_to_output_kernel(unsigned int* const  d_inputVals,unsigned int* const  d_outputPos,unsigned int* const d_outputVals,size_t n){
    luint total_threads = blockDim.x * gridDim.x;
    luint elements_per_thread = n / total_threads + ((n % total_threads) > 0);
    luint global_idx = (luint ) blockDim.x * (luint ) blockIdx.x
            + (luint) threadIdx.x;
    luint start = global_idx * elements_per_thread;

    if (start >= n) {
        //printf("t,b=%d,%d no work\n",blockIdx.x, threadIdx.x);
        return;
    }
    luint end = min((luint) n, start + elements_per_thread);

    for (; start < end; start++) {
        d_outputVals[d_outputPos[start]]=d_inputVals[start];
    }

}
void copy_to_output(unsigned int* const  d_inputVals,unsigned int* const  d_outputPos,unsigned int* const d_outputVals,size_t n){
    int threads = min(n, count_max_threads_per_block);
    size_t blocks_required_with_one_element_per_thread = n / threads + ((n % threads) > 0);
    int blocks = min(blocks_required_with_one_element_per_thread, max_blocks);
    const dim3 blockSize(threads);
    const dim3 gridSize(blocks);

    copy_to_output_kernel<<<gridSize, blockSize, 1>>>(d_inputVals,d_outputPos,d_outputVals,n);

}
__global__
void generate_output_positions_kernel(unsigned int* const  d_inputVals,unsigned int* const  d_outputPos,size_t n,unsigned int bit_mask,luint* d_indices){

}

void generate_output_positions(unsigned int* const  d_inputVals,unsigned int* const  d_outputPos,size_t n,unsigned int bit_mask,luint h_start_ones){

    luint* d_indices;
    checkCudaErrors(cudaMalloc(&d_indices, sizeof(luint) * 2));
    checkCudaErrors(cudaMemset(d_indices, 0, sizeof(luint) * 1));
    checkCudaErrors(cudaMemset(&d_indices[1], h_start_ones, sizeof(luint) * 1));


    generate_output_positions_kernel<<<1,1,1>>>(d_inputVals,d_outputPos,n,bit_mask,d_indices);
}

void your_sort(unsigned int* d_inputVals, unsigned int* d_inputPos, unsigned int* d_outputVals,
        unsigned int* d_outputPos, size_t n) {

    unsigned int bits = sizeof(unsigned int) * 8;
    luint* d_count;
    checkCudaErrors(cudaMalloc(&d_count, sizeof(luint) * 1));

    unsigned int bit_mask = 1;

    for (unsigned int bit_index = 0; bit_index < bits; bit_index++) {
        //printf("Bit index %d\n", bit_index);
        count_match_bitmask(d_inputVals, n, d_count, bit_mask);
        cudaDeviceSynchronize();
        luint  h_count;
        checkCudaErrors(cudaMemcpy(&h_count, d_count, sizeof(luint) * 1, cudaMemcpyDeviceToHost));
        luint h_start_ones=n-h_count;
//        printf("d_Count %llu out of %lu\n", h_count, n);
//        h_count = 0;
//        unsigned int* h_inputVals = new unsigned int[n];
//        checkCudaErrors(cudaMemcpy(h_inputVals, d_inputVals, sizeof(unsigned int) * n, cudaMemcpyDeviceToHost));
//        for (size_t i = 0; i < n; i++) {
//            if (h_inputVals[i] & bit_mask) {
//                h_count++;
//            }
//        }
//        printf("h_count %llu out of %lu\n", h_count, n);

        //generate_output_positions(d_inputVals,d_outputPos,n,bit_mask,h_start_ones);
        // I refuse to code yet another blelloch scan with a slightly different input and output

        unsigned int* h_inputVals= new unsigned int[n];
        unsigned int* h_outputPos= new unsigned int[n];

        checkCudaErrors(cudaMemcpy(h_inputVals, d_inputVals, sizeof(unsigned int) * n, cudaMemcpyDeviceToHost));
        checkCudaErrors(cudaMemcpy(h_outputPos, d_outputPos, sizeof(unsigned int) * n, cudaMemcpyDeviceToHost));
        //printf("%lu/%lu start\n",h_start_ones,n);
        size_t zeros=0;
        size_t ones=h_start_ones;
        for (size_t i=0;i<n;i++){
            if ( (h_inputVals[i] & bit_mask)){
                h_outputPos[i]=ones;
                ones++;
            }else{
                h_outputPos[i]=zeros;
                zeros++;
            }
        }
        checkCudaErrors(cudaMemcpy(d_outputPos, h_outputPos, sizeof(unsigned int) * n, cudaMemcpyHostToDevice));

        copy_to_output(d_inputVals,d_outputPos,d_outputVals,n);
        // swap input and output
        unsigned int* temp=d_outputVals;
        d_outputVals=d_inputVals;
        d_inputVals=temp;
        free(h_inputVals);
        free(h_outputPos);
        bit_mask <<= 1;
    }
    checkCudaErrors(cudaMemcpy(d_outputPos, d_inputPos, sizeof(unsigned int) * n, cudaMemcpyDeviceToDevice));

}
