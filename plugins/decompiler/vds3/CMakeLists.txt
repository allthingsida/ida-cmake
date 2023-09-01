cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(invert_if)

# Plugin 1
set(CMAKE_CXX_STANDARD 17)

include($ENV{IDASDK}/ida-cmake/common.cmake)

set(PLUGIN_NAME              invert_if)
set(PLUGIN_SOURCES           hexrays_sample3.cpp)
set(PLUGIN_RUN_ARGS          "-t -z10000") # Debug messages for the debugger
generate()
disable_ida_warnings(invert_if)
