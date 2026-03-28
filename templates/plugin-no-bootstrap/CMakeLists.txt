# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) Elias Bachaalany

cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

find_package(idasdk REQUIRED)

# Add plugin
ida_add_plugin(myplugin
    SOURCES
        main.cpp
    DEBUG_ARGS
        "-t -z10000"
)