cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(TwoPlugins)

set(CMAKE_CXX_STANDARD 17)

include($ENV{IDASDK}/ida-cmake/common.cmake)

# Plugin 1
set(PLUGIN_NAME              mysample1)
set(PLUGIN_SOURCES           mysample1.cpp)
generate()

# Plugin 2
set(PLUGIN_NAME              mysample2)
set(PLUGIN_SOURCES           mysample2.cpp)
generate()

