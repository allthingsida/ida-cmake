# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) Elias Bachaalany

cmake_minimum_required(VERSION 3.27)
project(myloader)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/src/cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Convert paths to native format
set(SAMPLE_FILE "${IDA_CMAKE_DIR}/samples/myff.bin")
file(TO_NATIVE_PATH "${SAMPLE_FILE}" SAMPLE_FILE)

# Add loader
ida_add_loader(myloader
    SOURCES
        loader.cpp
    DEBUG_ARGS
        "${SAMPLE_FILE}"
)