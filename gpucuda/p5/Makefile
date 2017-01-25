NVCC=nvcc
NVCC_OPTS=-O3 -arch=sm_50 -Xcompiler -Wall -Xcompiler -Wextra -m64
CUDA_INCLUDEPATH=/usr/local/cuda/include  
GCC_OPTS=-O3 -Wall -Wextra -m64


all: main.o reference_calc.o student.o Makefile
	nvcc -o HW5 main.o reference_calc.o student.o $(NVCC_OPTS)

main.o: main.cu utils.h
	$(NVCC) -c main.cu  $(NVCC_OPTS)
	
reference_calc.o: reference_calc.cpp reference_calc.h
	g++ -c reference_calc.cpp  $(GCC_OPTS) -I $(CUDA_INCLUDEPATH)
	
student.o: student.cu reference_calc.cpp utils.h
	nvcc -c student.cu $(NVCC_OPTS)

clean:
	rm -f *.o hw *.bin
