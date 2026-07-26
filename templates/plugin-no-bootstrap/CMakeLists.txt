# Copyright (c) 2019-2026 Elias Bachaalany
# SPDX-License-Identifier: LicenseRef-Human-Origin-Source-1.0
#
# This file is licensed under the Human-Origin Source License v1.0.
# See LICENSE.

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