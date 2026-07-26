# Copyright (c) 2019-2026 Elias Bachaalany
# SPDX-License-Identifier: LicenseRef-Human-Origin-Source-1.0
#
# This file is licensed under the Human-Origin Source License v1.0.
# See LICENSE.

cmake_minimum_required(VERSION 3.27)
project(i51)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Add processor module
ida_add_procmod(i51
    SOURCES
        ana.cpp
        emu.cpp
        out.cpp
        reg.cpp
        ins.cpp
        merge.cpp
    INCLUDES
        ${IDASDK}/module  # For ../idaidp.hpp, ../iohandler.hpp and ../mergecmn.cpp
    OUTPUT_NAME i51
    DEBUG_ARGS
        "-c -A"  # Common processor module debug args
)