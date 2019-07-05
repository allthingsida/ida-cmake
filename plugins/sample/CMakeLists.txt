cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(mysample)

# Plugin 1
set(PLUGIN_NAME              mysample)
set(PLUGIN_SOURCES           mysample.cpp)
set(PLUGIN_RUN_ARGS          "-t -z10000") # Debug messages for the debugger
include($ENV{IDASDK}/ida-cmake/plugins.cmake)
