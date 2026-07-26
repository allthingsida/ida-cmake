# Copyright (c) 2019-2026 Elias Bachaalany
# SPDX-License-Identifier: LicenseRef-Human-Origin-Source-1.0
#
# This file is licensed under the Human-Origin Source License v1.0.
# See LICENSE.

# IDA SDK CMake Bootstrap
# This file sets up the CMAKE_PREFIX_PATH and MODULE_PATH to find the IDASDK package
# Usage: include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)

# Resolve the SDK root. A -DIDASDK=<path> cache variable takes precedence over
# the IDASDK environment variable, so an alternate SDK (e.g. a 9.4 working copy)
# can be selected per build without changing the global environment.
if(DEFINED IDASDK AND NOT IDASDK STREQUAL "")
    set(_IDASDK_ROOT "${IDASDK}")
elseif(DEFINED ENV{IDASDK})
    set(_IDASDK_ROOT "$ENV{IDASDK}")
else()
    message(FATAL_ERROR "IDASDK not set. Pass -DIDASDK=<path> or set the IDASDK environment variable to your IDA SDK directory.")
endif()

# Validate the SDK path exists
if(NOT EXISTS "${_IDASDK_ROOT}")
    message(FATAL_ERROR "IDASDK path does not exist: ${_IDASDK_ROOT}")
endif()

# Auto-detect SDK structure: GitHub clone has files under src/, zip distribution at root
set(_IDASDK_ACTUAL "${_IDASDK_ROOT}")
if(NOT EXISTS "${_IDASDK_ACTUAL}/include/pro.h")
    # Check if this is a GitHub clone with src/ subdirectory
    if(EXISTS "${_IDASDK_ACTUAL}/src/include/pro.h")
        set(_IDASDK_ACTUAL "${_IDASDK_ACTUAL}/src")
        message(STATUS "Detected GitHub SDK structure, using: ${_IDASDK_ACTUAL}")
    else()
        message(FATAL_ERROR "Invalid IDASDK directory (missing include/pro.h): ${_IDASDK_ROOT}")
    endif()
endif()

# Propagate the resolved path via both the environment variable (backward compat)
# and the IDASDK cache variable, so find_package(idasdk)/idasdkConfig.cmake use it.
set(ENV{IDASDK} "${_IDASDK_ACTUAL}")
set(IDASDK "${_IDASDK_ACTUAL}" CACHE PATH "Path to the IDA SDK" FORCE)

# Add ida-cmake to the package search path
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_LIST_DIR})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

# Set default minimum CMake version if not already set
if(CMAKE_MINIMUM_REQUIRED_VERSION VERSION_LESS 3.27)
    cmake_minimum_required(VERSION 3.27)
endif()