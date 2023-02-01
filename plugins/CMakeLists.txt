#
# CMake template for compiling more than one plugin
#
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(AllPlugins)

add_subdirectory(twoplugins)
add_subdirectory(sample)