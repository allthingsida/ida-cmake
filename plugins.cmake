# Include common configuration
include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

# Create a library for the current plugin
add_library(${PLUGIN_NAME} SHARED ${PLUGIN_SOURCES})

# Set the default plugin output name
if (NOT DEFINED PLUGIN_OUTPUT_NAME)
    set(PLUGIN_OUTPUT_NAME ${PLUGIN_NAME})
    message("Setting default plugin output file name to: ${PLUGIN_OUTPUT_NAME}")
endif()

if (DEFINED __NT__)
    target_compile_definitions(${PLUGIN_NAME} PRIVATE __NT__)
elseif(DEFINED __MAC__)
    target_compile_definitions(${PLUGIN_NAME} PRIVATE __MAC__)
elseif(DEFINED __LINUX__)
    target_compile_definitions(${PLUGIN_NAME} PRIVATE __LINUX__)
endif()

# 64bit addressing?
if (${EA64})
    target_compile_definitions(${PLUGIN_NAME} PRIVATE __EA64__=1)
    target_link_libraries(${PLUGIN_NAME} ${IDALIB64})

    set_target_properties(${PLUGIN_NAME} PROPERTIES OUTPUT_NAME ${PLUGIN_OUTPUT_NAME}64)
else()
    # Use x64 IDA 32bits addressing
    target_link_libraries(${PLUGIN_NAME} ${IDALIB32})
    set_target_properties(${PLUGIN_NAME} PROPERTIES OUTPUT_NAME ${PLUGIN_OUTPUT_NAME})
endif() 

# Set include directory
target_include_directories(${PLUGIN_NAME} PRIVATE ${IDASDK}/include)

# Set common defines
target_compile_definitions(${PLUGIN_NAME} PRIVATE __IDP__ MAXSTR=${MAXSTR})

# Adjust output folders
if (DEFINED __NT__)
    # On Windows and for release builds, statically link
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    # That's a Windows subsystem plugin (not Console)
    set_property(TARGET ${PLUGIN_NAME} APPEND_STRING PROPERTY LINK_FLAGS " /SUBSYSTEM:WINDOWS")

    # Set the destination folder to be in IDA's binary output folder
    foreach(cfg IN LISTS CMAKE_CONFIGURATION_TYPES)
        string(TOUPPER ${cfg} cfg)
        set_target_properties(${PLUGIN_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_${cfg} ${IDABIN}/plugins)
    endforeach()
else()
    # Set the destination folder to be in IDA's binary output folder
    set_target_properties(${PLUGIN_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${IDABIN}/plugins)
    set_target_properties(${PLUGIN_NAME} PROPERTIES PREFIX "")
endif()

# Set convenience user debugging information for MSVC projects
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    if (NOT DEFINED PLUGIN_RUN_ARGS)
        set(PLUGIN_RUN_ARGS -t)
    endif()
    configure_file(
        "${CMAKE_CURRENT_LIST_DIR}/plugins.vcxproj.user" 
        "${PLUGIN_NAME}.vcxproj.user" 
        @ONLY)
endif()


unset(PLUGIN_OUTPUT_NAME)
unset(PLUGIN_RUN_ARGS)