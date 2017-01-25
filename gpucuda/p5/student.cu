/* Udacity HW5
 Histogramming for Speed

 The goal of this assignment is compute a histogram
 as fast as possible.  We have simplified the problem as much as
 possible to allow you to focus solely on the histogramming algorithm.

 The input values that you need to histogram are already the exact
 bins that need to be updated.  This is unlike in HW3 where you needed
 to compute the range of the data and then do:
 bin = (val - valMin) / valRange to determine the bin.

 Here the bin is just:
 bin = val

 so the serial histogram calculation looks like:
 for (i = 0; i < numElems; ++i)
 histo[val[i]]++;

 That's it!  Your job is to make it run as fast as possible!

 The values are normally distributed - you may take
 advantage of this fact in your implementation.

 */

#include "utils.h"
#include <thrust/host_vector.h>

__global__
void yourHisto(const unsigned int* const d_vals, //INPUT
        unsigned int* const d_histo,      //OUPUT
        int numVals,const unsigned int numBins) {

    __shared__ unsigned int histogram[1];
    // Initialize shared block array with local histogram to 0
    if (threadIdx.x==0){
            histogram[0]=0;
    }
    __syncthreads();

    //const int elems_per_thread = numVals/blockDim.x;
    //const int start= elems_per_thread * threadIdx.x;
    //int end= start+elems_per_thread;
    //if (threadIdx.x==(blockDim.x-1)){
      //  end=numVals;
    //}

    // get id and check if it is a valid index
    int count=0;
    for (int i=threadIdx.x;i<numVals;i+=blockDim.x){
         if (d_vals[i]==blockIdx.x){
             count++;
         }
    }
    // each thread updates its local histogram
    atomicAdd(&histogram[0], count);

    __syncthreads();
    // Copy shared block array with local histogram to global histogram
    if (threadIdx.x==0){
         d_histo[blockIdx.x]=histogram[0];

    }
}

void computeHistogram(const unsigned int* const d_vals, //INPUT
        unsigned int* const d_histo,      //OUTPUT
        const unsigned int numBins,  unsigned int numElems) {
    //numElems=1024;

    const int threads_per_block=128;
    const int blocks = numElems /threads_per_block + ((numElems % threads_per_block) > 0) ;

    //printf("blocks %d, threads per block %d, numbins %d, numelems %d\n",blocks,threads_per_block,numBins,numElems);
    yourHisto<<<numBins, threads_per_block>>>(d_vals, d_histo, numElems,numBins);

    cudaDeviceSynchronize();
    checkCudaErrors(cudaGetLastError());
}
