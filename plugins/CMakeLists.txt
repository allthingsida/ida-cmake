cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

set(PLUGIN_NAME              mysample)
set(PLUGIN_SOURCES           mysample.cpp)

include($ENV{IDASDK}/ida-cmake/plugins.cmake)
