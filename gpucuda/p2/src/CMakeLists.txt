cmake_minimum_required(VERSION 3.5)
############################################################################
# <summary> CMakeLists.txt for OpenCV and CUDA. </summary>
# <date>    2012-02-07          </date>
# <author>  Quan Tran Minh. edit by Johannes Kast, Michael Sarahan </author>
# <email>   quantm@unist.ac.kr  kast.jo@googlemail.com msarahan@gmail.com</email>
############################################################################
project( HW2 )

# collect source files
#OPENCV_LIBPATH="/usr/lib/x86_64-linux-gnu/"
#OPENCV_INCLUDEPATH="/usr/include/opencv"

#OPENCV_LIBS="-lopencv_core -lopencv_imgproc -lopencv_highgui"
#CUDA_INCLUDEPATH="/usr/local/cuda/include" 
find_package(CUDA REQUIRED )
find_package( OpenCV REQUIRED core imgproc )

file( GLOB  hdr *.hpp *.h )
file( GLOB  cu  *.cu)
SET (HW2_files main.cpp reference_calc.cpp compare.cpp)
    
cuda_add_executable(HW2 ${HW2_files} ${hdr} ${cu})

target_link_libraries(HW2 ${OpenCV_LIBS} )
