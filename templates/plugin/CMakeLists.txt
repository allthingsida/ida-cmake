# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) Elias Bachaalany

cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/src/cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Convert paths to native format
set(SAMPLE_IDB "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64")
file(TO_NATIVE_PATH "${SAMPLE_IDB}" SAMPLE_IDB)

# Add plugin
ida_add_plugin(myplugin
    SOURCES
        main.cpp
    DEBUG_ARGS
        "${SAMPLE_IDB}"
)
# IDA 9.x deployment with metadata (uncomment to use)
# Plugin deploys to: $IDABIN/plugins/myplugin/ with ida-plugin.json
# ida_add_plugin(myplugin
#     SOURCES
#         main.cpp
#     DEBUG_ARGS
#         "${SAMPLE_IDB}"
#     METADATA_JSON
#         ida-plugin.json
# )
