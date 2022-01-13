cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(TwoPlugins)

# Plugin 1
set(PLUGIN_NAME              mysample1)
set(PLUGIN_SOURCES           mysample1.cpp)
include($ENV{IDASDK}/ida-cmake/addons.cmake)

# Plugin 2
set(PLUGIN_NAME              mysample2)
set(PLUGIN_SOURCES           mysample2.cpp)
include($ENV{IDASDK}/ida-cmake/addons.cmake)
