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