project(${PLUGIN_NAME})

# Set and verify the SDK folder
set(IDASDK $ENV{IDASDK})

if (NOT EXISTS "${IDASDK}")
    message(FATAL "IDA SDK folder not found: ${IDASDK}")
endif()

# Default IDA binary folder is in the SDK's bin folder
set(IDABIN $ENV{IDABIN})
if (NOT EXISTS "${IDABIN}")
    set(IDABIN $ENV{IDASDK}/bin)
    message("Setting default IDABIN folder to: ${IDABIN}")
endif()

# Create a library for the current plugin
add_library(${PLUGIN_NAME} SHARED ${PLUGIN_SOURCES})

# Set the default plugin output name
if (NOT DEFINED PLUGIN_OUTPUT_NAME)
    set(PLUGIN_OUTPUT_NAME ${PLUGIN_NAME})
    message("Setting default plugin output file name to: ${PLUGIN_OUTPUT_NAME}")
endif()

option(EA64 "64bit addressing" OFF)

if (${EA64})
    # Use __EA64__
    target_compile_definitions(${PLUGIN_NAME} PRIVATE __EA64__=1)

    # Link with x64 IDA 64bits addressing
    target_link_libraries(${PLUGIN_NAME} ${IDASDK}lib/x64_win_vc_64/ida.lib)

    set_target_properties(${PLUGIN_NAME} PROPERTIES OUTPUT_NAME ${PLUGIN_OUTPUT_NAME}64)
else()
    # Use x64 IDA 32bits addressing
    target_link_libraries(${PLUGIN_NAME} ${IDASDK}/lib/x64_win_vc_32/ida.lib)
    set_target_properties(${PLUGIN_NAME} PROPERTIES OUTPUT_NAME ${PLUGIN_OUTPUT_NAME})
endif() 

# Set include directory
target_include_directories(${PLUGIN_NAME} PRIVATE ${IDASDK}/include)

# Set common defines
target_compile_definitions(${PLUGIN_NAME} PRIVATE __NT__ __IDP__ MAXSTR=1024)

# Set the destination folder to be in IDA's binary output folder
foreach(cfg IN LISTS CMAKE_CONFIGURATION_TYPES)
    string(TOUPPER ${cfg} cfg)
    set_target_properties(${PLUGIN_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_${cfg} ${IDABIN}/plugins)
endforeach()

# For release builds, statically link
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")