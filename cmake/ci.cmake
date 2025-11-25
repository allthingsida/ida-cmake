# ci.cmake - Build all ida-cmake templates for CI validation
# Usage: cmake -P cmake/ci.cmake
#
# Environment:
#   IDASDK - Path to IDA SDK (required, ida-cmake must be at $IDASDK/ida-cmake)

cmake_minimum_required(VERSION 3.27)

# Get script directory (ida-cmake root)
get_filename_component(IDA_CMAKE_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# Validate IDASDK
if(NOT DEFINED ENV{IDASDK})
    message(FATAL_ERROR "IDASDK environment variable not set")
endif()
set(IDASDK "$ENV{IDASDK}")

message(STATUS "===========================================")
message(STATUS "ida-cmake CI - Building all templates")
message(STATUS "===========================================")
message(STATUS "IDA_CMAKE_ROOT: ${IDA_CMAKE_ROOT}")
message(STATUS "IDASDK: ${IDASDK}")

# Detect generator and build type args
if(WIN32)
    set(GENERATOR_ARGS -A x64)
    set(BUILD_ARGS --config Release)
else()
    set(GENERATOR_ARGS -DCMAKE_BUILD_TYPE=Release)
    set(BUILD_ARGS "")
endif()

# Templates to build (relative to templates/)
set(TEMPLATES
    plugin
    plugin-vanilla
    plugin-no-bootstrap
    loader
    procmod
    idalib
    idalib-vanilla
)

set(FAILED_TEMPLATES "")
set(PASSED_TEMPLATES "")

foreach(TEMPLATE ${TEMPLATES})
    set(TEMPLATE_DIR "${IDA_CMAKE_ROOT}/templates/${TEMPLATE}")
    set(BUILD_DIR "${IDA_CMAKE_ROOT}/build-ci/${TEMPLATE}")

    message(STATUS "")
    message(STATUS "-------------------------------------------")
    message(STATUS "Building: ${TEMPLATE}")
    message(STATUS "-------------------------------------------")

    # Clean build directory
    file(REMOVE_RECURSE "${BUILD_DIR}")
    file(MAKE_DIRECTORY "${BUILD_DIR}")

    # Special handling for plugin-no-bootstrap (needs CMAKE_PREFIX_PATH)
    if(TEMPLATE STREQUAL "plugin-no-bootstrap")
        set(EXTRA_ARGS -DCMAKE_PREFIX_PATH=${IDA_CMAKE_ROOT})
    else()
        set(EXTRA_ARGS "")
    endif()

    # Configure
    execute_process(
        COMMAND ${CMAKE_COMMAND}
            -S ${TEMPLATE_DIR}
            -B ${BUILD_DIR}
            ${GENERATOR_ARGS}
            ${EXTRA_ARGS}
        RESULT_VARIABLE CONFIG_RESULT
        OUTPUT_VARIABLE CONFIG_OUTPUT
        ERROR_VARIABLE CONFIG_ERROR
    )

    if(NOT CONFIG_RESULT EQUAL 0)
        message(STATUS "FAILED: ${TEMPLATE} (configure)")
        message(STATUS "Output: ${CONFIG_OUTPUT}")
        message(STATUS "Error: ${CONFIG_ERROR}")
        list(APPEND FAILED_TEMPLATES "${TEMPLATE}")
        continue()
    endif()

    # Build
    execute_process(
        COMMAND ${CMAKE_COMMAND}
            --build ${BUILD_DIR}
            ${BUILD_ARGS}
        RESULT_VARIABLE BUILD_RESULT
        OUTPUT_VARIABLE BUILD_OUTPUT
        ERROR_VARIABLE BUILD_ERROR
    )

    if(NOT BUILD_RESULT EQUAL 0)
        message(STATUS "FAILED: ${TEMPLATE} (build)")
        message(STATUS "Output: ${BUILD_OUTPUT}")
        message(STATUS "Error: ${BUILD_ERROR}")
        list(APPEND FAILED_TEMPLATES "${TEMPLATE}")
        continue()
    endif()

    message(STATUS "PASSED: ${TEMPLATE}")
    list(APPEND PASSED_TEMPLATES "${TEMPLATE}")
endforeach()

# Summary
message(STATUS "")
message(STATUS "===========================================")
message(STATUS "CI Summary")
message(STATUS "===========================================")

list(LENGTH PASSED_TEMPLATES PASSED_COUNT)
list(LENGTH FAILED_TEMPLATES FAILED_COUNT)

message(STATUS "Passed: ${PASSED_COUNT}")
foreach(T ${PASSED_TEMPLATES})
    message(STATUS "  - ${T}")
endforeach()

if(FAILED_COUNT GREATER 0)
    message(STATUS "Failed: ${FAILED_COUNT}")
    foreach(T ${FAILED_TEMPLATES})
        message(STATUS "  - ${T}")
    endforeach()
    message(FATAL_ERROR "CI failed: ${FAILED_COUNT} template(s) failed to build")
endif()

message(STATUS "")
message(STATUS "All templates built successfully!")
