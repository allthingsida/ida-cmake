cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(mysample)

set(CMAKE_CXX_STANDARD 17)

if (DEFINED IDASDK)
    include(${IDASDK}/ida-cmake/common.cmake)
elseif (DEFINED ENV{IDASDK})
    include($ENV{IDASDK}/ida-cmake/common.cmake)
else()
    message(FATAL_ERROR "IDA SDK folder not specified via the -D switch or the environment variable 'IDASDK'")
endif()

set(PLUGIN_NAME              mysample)
set(PLUGIN_SOURCES           mysample.cpp)
set(PLUGIN_RUN_ARGS          "-t -z10000") # Debug messages for the debugger

generate()
disable_ida_warnings(mysample)
