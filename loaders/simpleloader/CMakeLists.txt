cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(loader_template)

set(CMAKE_CXX_STANDARD 17)

set(LOADER_NAME    loader_template)
set(LOADER_SOURCES loader_template.cpp)

include($ENV{IDASDK}/ida-cmake/addons.cmake)