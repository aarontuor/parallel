#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

void printmatrix(float * mat, int n){
    int i, j;
    printf("\n");
    for (i = 0; i < n; i++){
        for (j = 0; j < n; j++){
            printf("%f ", mat[i*n + j]);
        }
        printf("\n");
    }
}

void writematrix(FILE *outfile, float * mat, int n){
    int i, j;
    for (i = 0; i < n; i++){
        for (j = 0; j < n; j++){
            fprintf(outfile, "%f ", mat[i*n + j]);
        }
        fprintf(outfile, "\n");
    }
}

__global__ void jacobi_iter(float *dmatrix, float *dmatrix2, float *fix_points, int n){
    int x = blockIdx.x;
    int y = threadIdx.x;
    if (fix_points[x*n + y] != 1.0){
        dmatrix2[x*n + y] = dmatrix[x*n + 1 + y]*0.25;
        dmatrix2[x*n + y] += dmatrix[x*n - 1 + y]*0.25;
        dmatrix2[x*n + y] += dmatrix[(x-1)*n + y]*0.25;
        dmatrix2[x*n + y] += dmatrix[(x+1)*n + y]*0.25;
    }
}

__global__ void max_diff_reduce(float *mat1, float *mat2, float *reduced_mat) {
    extern __shared__ float sdata[];

    // each thread loads one element from global to shared mem
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    sdata[tid] = mat1[i] - mat2[i];
	__syncthreads();
	// do reduction in shared mem
	for (unsigned int s=blockDim.x/2; s>0; s>>=1) {
		if (tid < s) {
			sdata[tid] = fmax((float)sdata[tid], (float)sdata[tid + s]);
		}
		__syncthreads();
	}
	// write result for this block to global mem
	if (tid == 0) {
		reduced_mat[blockIdx.x] = sdata[0];
	}
}



int main(int argc, char **argv){

    char * filename;
    filename =  argv[1];
    FILE *spec = fopen(filename, "r");
    FILE *outfile = fopen(argv[2], "w");
    int n, i, j, iter; //size of square matrix
    float delta; //for ending iterations
    int check;
    check = fscanf(spec, "%d %f\n", &n, &delta);
    int msize = n*n*sizeof(float);


    float *matrix = (float *)malloc(msize); //host matrix
    float *matrix2 = (float *)malloc(msize); //host matrix
    float *fix_points = (float *)malloc(msize); //host matrix
    for (i = 0; i < n*n; i++){
         fix_points[i] = 0.0;
    }
	float *reduced_mat = (float *)malloc(n*sizeof(float));
    float *dmatrix; // kernel matrix for alternating
    cudaMalloc((void**) &dmatrix, msize);
    float *dmatrix2; // kernel matrix for alternating
    cudaMalloc((void**) &dmatrix2, msize);
    float *dfix_points; // kernel matrix fixed points
    cudaMalloc((void**) &dfix_points, msize);
	float *dreduced_mat;
	cudaMalloc((void**) &dreduced_mat, n*sizeof(float));

	int urow, ucol, drow, dcol;
    float val;

    while (fscanf(spec, "\n%f %d %d %d %d\n", &val, &urow, &ucol, &drow, &dcol) == 5){
        printf("%f %d %d %d %d\n", val, urow, ucol, drow, dcol);
        for (i=urow; i<=drow; i++){
            for(j=ucol; j<=dcol; j++){
                matrix[i*n + j] = val;
                fix_points[i*n + j] = 1.0;
            }
        }
    }
    //printmatrix(matrix, n);
    fclose(spec);
    //printf("msize: %d delta %f\n", n*n, delta);
    cudaMemcpy(dmatrix, matrix, msize, cudaMemcpyHostToDevice);
    cudaMemcpy(dmatrix2, matrix, msize, cudaMemcpyHostToDevice);
    cudaMemcpy(dfix_points, fix_points, msize, cudaMemcpyHostToDevice);
    float maxdiff = 2.0*delta;
    dim3 dimGrid(n,1);
    dim3 dimBlock(n,1,1);
    iter = 0;
    maxdiff = 3;
    while(maxdiff > delta){

        iter += 1;
        jacobi_iter<<<dimGrid, dimBlock>>>(dmatrix, dmatrix2, dfix_points, n);
        cudaThreadSynchronize();
        cudaMemcpy(matrix, dmatrix2, msize, cudaMemcpyDeviceToHost);
        jacobi_iter<<<dimGrid, dimBlock>>>(dmatrix2, dmatrix, dfix_points, n);
        cudaThreadSynchronize();
        cudaMemcpy(matrix2, dmatrix, msize, cudaMemcpyDeviceToHost);
        //max_diff_reduce<<<dimGrid, dimBlock>>>(dmatrix2, dmatrix, dreduced_mat);
		// cudaMemcpy(reduced_mat, dreduced_mat, n*sizeof(float), cudaMemcpyDeviceToHost);
        maxdiff = fabs(matrix[0] - matrix2[0]);
        //maxdiff = reduced_mat[0];
		for(i=1; i<n*n; i++){
		 	maxdiff = fmax((float) maxdiff, (float) fabs((matrix[i]-matrix2[i])));
		}
        printf("\niter: %d maxdiff: %f delta: %f\n", iter, maxdiff, delta);
	}
    cudaMemcpy(matrix, dmatrix2, msize, cudaMemcpyDeviceToHost);
    //printmatrix(matrix, n);
    cudaMemcpy(matrix, dmatrix, msize, cudaMemcpyDeviceToHost);
    //printmatrix(matrix, n);
    writematrix(outfile, matrix2, n);
    fclose(outfile);
}
