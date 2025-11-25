cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Standard CMake approach - create a shared library
add_library(myplugin SHARED main.cpp)

# Link against IDA SDK plugin interface target
# This provides all includes, definitions, and libraries needed
target_link_libraries(myplugin PRIVATE idasdk::plugin)

# Set output directories for the plugin
# Plugins are deployed to $IDABIN/plugins/
set_target_properties(myplugin PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${IDABIN}/plugins"
    LIBRARY_OUTPUT_DIRECTORY "${IDABIN}/plugins"
)

# Platform-specific settings
if(UNIX)
    # Remove "lib" prefix on Unix systems (plugin, not libplugin)
    set_target_properties(myplugin PROPERTIES PREFIX "")
endif()

if(WIN32)
    # Windows plugins need SUBSYSTEM:WINDOWS
    target_link_options(myplugin PRIVATE /SUBSYSTEM:WINDOWS)
endif()

# Optional: Suppress warnings from IDA SDK headers
ida_disable_warnings(myplugin)

# Optional: Add custom libraries, includes, or defines
# target_link_libraries(myplugin PRIVATE Boost::filesystem)
# target_include_directories(myplugin PRIVATE ${CMAKE_SOURCE_DIR}/include)
# target_compile_definitions(myplugin PRIVATE MY_DEBUG=1)

# Optional: Configure debugging
if(CMAKE_GENERATOR MATCHES "Visual Studio" OR CMAKE_GENERATOR MATCHES "Ninja Multi-Config")
    # For multi-config generators
    set_target_properties(myplugin PROPERTIES
        VS_DEBUGGER_COMMAND "$<IF:$<STREQUAL:${IDA_ARCH},x86>,${IDABIN}/idat.exe,${IDABIN}/idat64.exe>"
        VS_DEBUGGER_COMMAND_ARGUMENTS "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64"
    )
else()
    # For single-config generators (Makefile, Ninja)
    set_target_properties(myplugin PROPERTIES
        VS_DEBUGGER_COMMAND "${IDABIN}/idat64.exe"
        VS_DEBUGGER_COMMAND_ARGUMENTS "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64"
    )
endif()
