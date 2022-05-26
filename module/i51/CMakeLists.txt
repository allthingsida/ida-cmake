# CMakeLists for the i51 processor module sample from the IDA SDK

cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(i51)

set(PROCMOD_NAME    i51)
set(PROCMOD_SOURCES ana.cpp emu.cpp i51.hpp ins.cpp ins.hpp out.cpp reg.cpp)
                    
include($ENV{IDASDK}/ida-cmake/addons.cmake)