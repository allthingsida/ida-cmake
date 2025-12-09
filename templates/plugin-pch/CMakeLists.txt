cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Convert paths to native format
set(SAMPLE_IDB "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64")
file(TO_NATIVE_PATH "${SAMPLE_IDB}" SAMPLE_IDB)

# Add plugin
ida_add_plugin(myplugin
    SOURCES
        main.cpp
        plugin.h
        pch.h
    DEBUG_ARGS
        "${SAMPLE_IDB}"
)

# ============================================================================
# Precompiled Header Support
# ============================================================================
# PCH significantly speeds up compilation by pre-parsing stable headers.
# Disable with: cmake -B build -DUSE_PCH=OFF
# ============================================================================

option(USE_PCH "Use precompiled headers for faster builds" ON)

if(USE_PCH)
    target_precompile_headers(myplugin PRIVATE
        "$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch.h>"
    )
endif()

# IDA 9.x deployment with metadata (uncomment to use)
# Plugin deploys to: $IDABIN/plugins/myplugin/ with ida-plugin.json
# ida_add_plugin(myplugin
#     SOURCES
#         main.cpp
#         plugin.h
#         pch.h
#     DEBUG_ARGS
#         "${SAMPLE_IDB}"
#     METADATA_JSON
#         ida-plugin.json
# )
