cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(simpleloader)

set(LOADER_NAME  myloader)
set(LOADER_SOURCES src.cpp src.h)

include($ENV{IDASDK}/ida-cmake/addons.cmake)

set_source_files_properties(${DISABLED_SOURCES} PROPERTIES LANGUAGE "")
