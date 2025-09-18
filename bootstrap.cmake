# IDA SDK CMake Bootstrap
# This file sets up the CMAKE_PREFIX_PATH and MODULE_PATH to find the IDASDK package
# Usage: include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)

if(NOT DEFINED ENV{IDASDK})
    message(FATAL_ERROR "IDASDK environment variable not set. Please set it to your IDA SDK directory.")
endif()

# Validate IDASDK path exists and contains expected files
if(NOT EXISTS "$ENV{IDASDK}")
    message(FATAL_ERROR "IDASDK path does not exist: $ENV{IDASDK}")
endif()

if(NOT EXISTS "$ENV{IDASDK}/include/pro.h")
    message(FATAL_ERROR "Invalid IDASDK directory (missing include/pro.h): $ENV{IDASDK}")
endif()

# Add ida-cmake to the package search path
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_LIST_DIR})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

# Set default minimum CMake version if not already set
if(CMAKE_MINIMUM_REQUIRED_VERSION VERSION_LESS 3.27)
    cmake_minimum_required(VERSION 3.27)
endif()