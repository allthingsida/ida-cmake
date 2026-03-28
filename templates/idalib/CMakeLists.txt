# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) Elias Bachaalany

cmake_minimum_required(VERSION 3.27)
project(myidalib VERSION 1.0)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/src/cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Convert paths to native format
set(SAMPLE_IDB "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64")
file(TO_NATIVE_PATH "${SAMPLE_IDB}" SAMPLE_IDB)

# Add IDALib executable with sample IDB as debug argument
ida_add_idalib(myidalib
    TYPE EXECUTABLE  # Optional, default is EXECUTABLE
    SOURCES
        main.cpp
    DEBUG_ARGS
        "${SAMPLE_IDB}"
)

# idalib programs need to have IDA in the path folder
if(MSVC)
    file(TO_NATIVE_PATH "${IDABIN}" IDABIN_NATIVE)
    set_target_properties(myidalib PROPERTIES
        VS_DEBUGGER_ENVIRONMENT "PATH=${IDABIN_NATIVE};%PATH%"
    )
endif()