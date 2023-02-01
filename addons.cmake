# For backwards compatibility, include the common configuration
include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

if (DEFINED PLUGIN_NAME)
    set(IS_PLUGIN 1)
    set(ADDON_KIND "plugin")
    set(ADDON_NAME ${PLUGIN_NAME})
    set(ADDON_SOURCES ${PLUGIN_SOURCES})
    unset(PLUGIN_SOURCES)
    set(ADDON_BIN "plugins")
    if (DEFINED PLUGIN_OUTPUT_NAME)
        set(ADDON_OUTPUT_NAME ${PLUGIN_OUTPUT_NAME})
        unset(PLUGIN_OUTPUT_NAME)
    endif()
    # Linker
    if (DEFINED PLUGIN_LINK_LIBRARIES)
        set(ADDON_LINK_LIBRARIES ${PLUGIN_LINK_LIBRARIES})
        unset(PLUGIN_LINK_LIBRARIES)
    endif()
    # Include directories
    if (DEFINED PLUGIN_INCLUDE_DIRECTORIES)
        set(ADDON_INCLUDE_DIRECTORIES ${PLUGIN_INCLUDE_DIRECTORIES})
        unset(PLUGIN_INCLUDE_DIRECTORIES)
    endif()
    if (NOT DEFINED PLUGIN_RUN_ARGS)
        set(PLUGIN_RUN_ARGS "-t")
    endif()
elseif(DEFINED LOADER_NAME)
    set(IS_LOADER 1)
    set(ADDON_KIND "file loader")
    set(ADDON_NAME ${LOADER_NAME})
    set(ADDON_SOURCES ${LOADER_SOURCES})
    set(ADDON_BIN "loaders")
    if (DEFINED LOADER_OUTPUT_NAME)
        set(ADDON_OUTPUT_NAME ${LOADER_OUTPUT_NAME})
        unset(LOADER_OUTPUT_NAME)
    endif()
    # Linker
    if (DEFINED LOADER_LINK_LIBRARIES)
        set(ADDON_LINK_LIBRARIES ${LOADER_LINK_LIBRARIES})
        unset(LOADER_LINK_LIBRARIES)
    endif()
    # Include directories
    if (DEFINED LOADER_INCLUDE_DIRECTORIES)
        set(ADDON_INCLUDE_DIRECTORIES ${LOADER_INCLUDE_DIRECTORIES})
        unset(LOADER_INCLUDE_DIRECTORIES)
    endif()
    if (NOT DEFINED LOADER_RUN_ARGS)
        set(LOADER_RUN_ARGS "-c -A")
    endif()
elseif(DEFINED PROCMOD_NAME)
    set(IS_PROCMOD 1)
    set(ADDON_KIND "processor module")
    set(ADDON_NAME ${PROCMOD_NAME})
    set(ADDON_SOURCES ${PROCMOD_SOURCES})
    set(ADDON_BIN "procs")
    if (DEFINED PROCMOD_OUTPUT_NAME)
        set(ADDON_OUTPUT_NAME ${PROCMOD_OUTPUT_NAME})
        unset(PROCMOD_OUTPUT_NAME)
    endif()
    # Linker
    if (DEFINED PROCMOD_LINK_LIBRARIES)
        set(ADDON_LINK_LIBRARIES ${PROCMOD_LINK_LIBRARIES})
        unset(PROCMOD_LINK_LIBRARIES)
    endif()
    # Include directories
    if (DEFINED PROCMOD_INCLUDE_DIRECTORIES)
        set(ADDON_INCLUDE_DIRECTORIES ${PROCMOD_INCLUDE_DIRECTORIES})
        unset(PROCMOD_INCLUDE_DIRECTORIES)
    endif()
    if (NOT DEFINED PROCMOD_RUN_ARGS)
        set(PROCMOD_RUN_ARGS "-c -A")
    endif()
endif()

# Create a library for the current plugin
add_library(${ADDON_NAME} SHARED ${ADDON_SOURCES})

# Set the default plugin output name
if (NOT DEFINED ADDON_OUTPUT_NAME)
    set(ADDON_OUTPUT_NAME ${ADDON_NAME})
    message("-- Setting the default ${ADDON_KIND} output file name to: ${ADDON_OUTPUT_NAME}")
endif()

if (DEFINED __NT__)
    target_compile_definitions(${ADDON_NAME} PRIVATE __NT__)
elseif(DEFINED __MAC__)
    target_compile_definitions(${ADDON_NAME} PRIVATE __MAC__)
elseif(DEFINED __LINUX__)
    target_compile_definitions(${ADDON_NAME} PRIVATE __LINUX__)
endif()

# 64bit addressing?
if (${EA64})
    target_compile_definitions(${ADDON_NAME} PRIVATE __EA64__=1)
    target_link_libraries(${ADDON_NAME} ${IDALIB64} ${ADDON_LINK_LIBRARIES})
    set_target_properties(${ADDON_NAME} PROPERTIES OUTPUT_NAME ${ADDON_OUTPUT_NAME}64)
else()
    # Use x64 IDA 32bits addressing
    target_link_libraries(${ADDON_NAME} ${IDALIB32} ${ADDON_LINK_LIBRARIES})
    set_target_properties(${ADDON_NAME} PROPERTIES OUTPUT_NAME ${ADDON_OUTPUT_NAME})
endif() 

# Set include directory
target_include_directories(${ADDON_NAME} PRIVATE ${IDASDK}/include ${ADDON_INCLUDE_DIRECTORIES})

# Set common defines
target_compile_definitions(${ADDON_NAME} PRIVATE __IDP__ MAXSTR=${MAXSTR})

# Adjust output folders
if (DEFINED __NT__)
    # On Windows and for release builds, statically link
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    # That's a Windows subsystem plugin (not Console)
    set_property(TARGET ${ADDON_NAME} APPEND_STRING PROPERTY LINK_FLAGS " /SUBSYSTEM:WINDOWS")

    # Set the destination folder to be in IDA's binary output folder
    foreach (cfg IN LISTS CMAKE_CONFIGURATION_TYPES)
        string(TOUPPER ${cfg} cfg)
        set_target_properties(${ADDON_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_${cfg} ${IDABIN}/${ADDON_BIN})
    endforeach()
else()
    # Set the destination folder to be in IDA's binary output folder
    set_target_properties(${ADDON_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${IDABIN}/${ADDON_BIN})
    set_target_properties(${ADDON_NAME} PROPERTIES PREFIX "")
endif()

if (DEFINED IS_PLUGIN)
    # Set convenience user debugging information for MSVC projects
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        configure_file(
            "${CMAKE_CURRENT_LIST_DIR}/plugins.vcxproj.user" 
            "${PLUGIN_NAME}.vcxproj.user" 
            @ONLY)
    endif()
elseif(DEFINED IS_LOADER)
    # Set convenience user debugging information for MSVC projects
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        configure_file(
            "${CMAKE_CURRENT_LIST_DIR}/loaders.vcxproj.user" 
            "${LOADER_NAME}.vcxproj.user" 
            @ONLY)
    endif()
elseif(DEFINED IS_PROCMOD)
    # Set convenience user debugging information for MSVC projects
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        configure_file(
            "${CMAKE_CURRENT_LIST_DIR}/procmod.vcxproj.user" 
            "${PROCMOD_NAME}.vcxproj.user" 
            @ONLY)
    endif()
endif()

unset(ADDON_OUTPUT_NAME)
unset(ADDON_NAME)
unset(ADDON_BIN)
unset(ADDON_SOURCES)
unset(ADDON_LINK_LIBRARIES)
unset(ADDON_KIND)
unset(PLUGIN_NAME)
unset(PLUGIN_RUN_ARGS)
unset(LOADER_NAME)
unset(LOADER_RUN_ARGS)
unset(PROCMOD_NAME)
unset(PROCMOD_RUN_ARGS)

# Mark disabled source files
set_source_files_properties(${DISABLED_SOURCES} PROPERTIES LANGUAGE "")
