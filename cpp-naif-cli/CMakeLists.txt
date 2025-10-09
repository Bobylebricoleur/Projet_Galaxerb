cmake_minimum_required(VERSION 3.9 FATAL_ERROR)
#
#
SET(CMAKE_CXX_STANDARD    17)    # 17 choisi pour metal
SET(CMAKE_BUILD_TYPE Release)
#
# To be enable for target with NVIDIA GPUs
#
SET(CMAKE_CXX_FLAGS "-march=native -mtune=native -Ofast -ffast-math")
#
#
#########################################################################################################################
#
#
#
project(main)
#
set(SOURCE_FILES
        ./src/main.cpp)
#
add_executable(main ${SOURCE_FILES})
#
#
#########################################################################################################################
