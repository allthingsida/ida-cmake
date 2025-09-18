# idasdkConfig.cmake
# CMake package configuration for IDA SDK

# Set IDASDK directory
if(NOT DEFINED IDASDK)
    if(DEFINED ENV{IDASDK})
        set(IDASDK "$ENV{IDASDK}")
    else()
        message(FATAL_ERROR "IDASDK environment variable not set")
    endif()
endif()

# Set IDABIN directory (default to $IDASDK/bin if not specified)
if(NOT DEFINED IDABIN)
    if(DEFINED ENV{IDABIN})
        set(IDABIN "$ENV{IDABIN}")
    else()
        set(IDABIN "${IDASDK}/bin")
    endif()
endif()

# Normalize paths
file(TO_CMAKE_PATH "${IDASDK}" IDASDK)
file(TO_CMAKE_PATH "${IDABIN}" IDABIN)

# Export ida-cmake directory for use by templates and projects
set(IDA_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE PATH "Path to ida-cmake directory")

# Always use EA64 (64-bit addressing)

# Include our CMake modules
include(${CMAKE_CURRENT_LIST_DIR}/cmake/platform.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/compiler.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/targets.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/utilities.cmake)

# Create interface targets
if(NOT TARGET idasdk::plugin)
    add_library(idasdk::plugin INTERFACE IMPORTED)
    set_target_properties(idasdk::plugin PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${IDASDK}/include"
        INTERFACE_COMPILE_DEFINITIONS "__IDP__"
    )

    # Always use EA64
    target_compile_definitions(idasdk::plugin INTERFACE __EA64__)

    # Link to platform and compiler settings
    target_link_libraries(idasdk::plugin INTERFACE
        ida_platform_settings
        ida_compiler_settings
        "${IDA_LIB_DIR}/${IDA_LIB_NAME}")
endif()

if(NOT TARGET idasdk::loader)
    add_library(idasdk::loader INTERFACE IMPORTED)
    set_target_properties(idasdk::loader PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${IDASDK}/include;${IDASDK}/ldr"
        INTERFACE_COMPILE_DEFINITIONS "__LOADER__"
    )

    # Loaders inherit all settings from plugins
    target_link_libraries(idasdk::loader INTERFACE idasdk::plugin)
endif()

if(NOT TARGET idasdk::procmod)
    add_library(idasdk::procmod INTERFACE IMPORTED)
    set_target_properties(idasdk::procmod PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${IDASDK}/include;${IDASDK}/module"
        INTERFACE_COMPILE_DEFINITIONS "__IDP__"
    )

    # Processor modules inherit all settings from plugins
    target_link_libraries(idasdk::procmod INTERFACE idasdk::plugin)
endif()

# IDALib support (if requested)
if("IDALib" IN_LIST idasdk_FIND_COMPONENTS)
    if(NOT TARGET idasdk::idalib)
        add_library(idasdk::idalib INTERFACE IMPORTED)
        set_target_properties(idasdk::idalib PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${IDASDK}/include"
            INTERFACE_COMPILE_DEFINITIONS "IDALIB_IMPL"
        )

        # Link to platform and compiler settings, plus BOTH idalib and ida libraries
        # Note: idalib.lib requires ida.lib for some symbols
        target_link_libraries(idasdk::idalib INTERFACE
            ida_platform_settings
            ida_compiler_settings
            "${IDA_LIB_DIR}/${IDALIB_NAME}"
            "${IDA_LIB_DIR}/${IDA_LIB_NAME}")
    endif()
endif()


# Detect SDK version
ida_check_sdk_version()

# Export package variables
set(idasdk_FOUND TRUE)
if(NOT DEFINED IDA_SDK_VERSION)
    set(idasdk_VERSION "unknown")
else()
    set(idasdk_VERSION "${IDA_SDK_VERSION}")
endif()
set(idasdk_INCLUDE_DIRS "${IDASDK}/include")
set(idasdk_LIBRARY_DIRS "${IDASDK}/lib")

# Include agent installation functionality
include(${CMAKE_CURRENT_LIST_DIR}/cmake/agent.cmake)
