# targets.cmake - Target creation functions for IDA SDK addons

# Create interface library for common addon properties
# This provides a way to propagate common settings to all addon targets
if(NOT TARGET ida_addon_base)
    add_library(ida_addon_base INTERFACE)

    # Common properties for all IDA addons
    target_compile_features(ida_addon_base INTERFACE cxx_std_17)

    # Position-independent code (required for shared libraries)
    set_target_properties(ida_addon_base PROPERTIES
        INTERFACE_POSITION_INDEPENDENT_CODE ON
    )

    # Link to common settings (these are inherited by all addons)
    # Note: ida_platform_settings and ida_compiler_settings are linked via IDASDK::* targets
endif()

# Internal function to handle common addon creation logic
function(_ida_create_addon_internal NAME TYPE SDK_TARGET OUTPUT_DIR)
    cmake_parse_arguments(ARG
        ""
        "OUTPUT_NAME;DEBUG_ARGS;DEBUG_PROGRAM;DEBUG_WORKING_DIR"
        "SOURCES;LIBRARIES;INCLUDES;DEFINES"
        ${ARGN}
    )

    # Create the addon as a shared library
    add_library(${NAME} SHARED ${ARG_SOURCES})

    # Link to base configuration and IDA SDK (order matters for property inheritance)
    target_link_libraries(${NAME}
        PRIVATE
            ida_addon_base    # Common addon properties
            ${SDK_TARGET}     # IDA SDK target (includes platform/compiler settings)
    )

    # Add user-specified libraries (after SDK to allow overrides)
    if(ARG_LIBRARIES)
        target_link_libraries(${NAME} PRIVATE ${ARG_LIBRARIES})
    endif()

    # Set target-specific properties using CMake patterns
    set_target_properties(${NAME} PROPERTIES
        # Output configuration
        RUNTIME_OUTPUT_DIRECTORY "$<1:${OUTPUT_DIR}>"
        LIBRARY_OUTPUT_DIRECTORY "$<1:${OUTPUT_DIR}>"
    )

    # Unix-specific: Remove "lib" prefix from addon names (macOS and Linux)
    if(APPLE OR UNIX)
        set_target_properties(${NAME} PROPERTIES PREFIX "")
    endif()

    # Windows-specific: Set subsystem to WINDOWS for addon DLLs
    # This prevents console windows from appearing when loaded by IDA
    if(WIN32)
        target_link_options(${NAME} PRIVATE /SUBSYSTEM:WINDOWS)
    endif()

    # Set output name if specified (can't use generator expression in property name)
    if(ARG_OUTPUT_NAME)
        set_target_properties(${NAME} PROPERTIES OUTPUT_NAME ${ARG_OUTPUT_NAME})
    endif()

    # Add user-specified includes (PRIVATE to not leak to dependents)
    if(ARG_INCLUDES)
        target_include_directories(${NAME} PRIVATE ${ARG_INCLUDES})
    endif()

    # Add user-specified defines (PRIVATE to not leak to dependents)
    if(ARG_DEFINES)
        target_compile_definitions(${NAME} PRIVATE ${ARG_DEFINES})
    endif()

    # CMake automatically sets the correct suffix for SHARED libraries based on platform
    # (.dll on Windows, .dylib on macOS, .so on Linux)

    # Debug configuration
    if(ARG_DEBUG_ARGS OR ARG_DEBUG_PROGRAM OR ARG_DEBUG_WORKING_DIR)
        # Default values - platform-specific IDA executable
        if(WIN32)
            set(DEBUG_PROG "${IDABIN}/ida.exe")
        else()
            set(DEBUG_PROG "${IDABIN}/ida")
        endif()
        if(ARG_DEBUG_PROGRAM)
            set(DEBUG_PROG ${ARG_DEBUG_PROGRAM})
        endif()

        set(DEBUG_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        if(ARG_DEBUG_WORKING_DIR)
            set(DEBUG_DIR ${ARG_DEBUG_WORKING_DIR})
        endif()

        # Visual Studio configuration
        if(MSVC)
            # Convert paths to native format for Visual Studio
            file(TO_NATIVE_PATH "${DEBUG_PROG}" DEBUG_PROG_NATIVE)
            file(TO_NATIVE_PATH "${DEBUG_DIR}" DEBUG_DIR_NATIVE)

            set_target_properties(${NAME} PROPERTIES
                VS_DEBUGGER_COMMAND "${DEBUG_PROG_NATIVE}"
                VS_DEBUGGER_COMMAND_ARGUMENTS "${ARG_DEBUG_ARGS}"
                VS_DEBUGGER_WORKING_DIRECTORY "${DEBUG_DIR_NATIVE}"
            )
        endif()

        # Generate VS Code config
        _ida_generate_vscode_config(${NAME} "${DEBUG_PROG}" "${ARG_DEBUG_ARGS}" "${DEBUG_DIR}")
    endif()

    # Disable IDA warnings by default
    ida_disable_warnings(${NAME})
endfunction()

# Helper function to generate VS Code launch.json
function(_ida_generate_vscode_config TARGET PROGRAM ARGS WORKING_DIR)
    set(VSCODE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/.vscode")
    if(NOT EXISTS "${VSCODE_DIR}/launch.json")
        file(MAKE_DIRECTORY ${VSCODE_DIR})

        # Escape paths for JSON
        string(REPLACE "\\" "\\\\" PROGRAM_JSON "${PROGRAM}")
        string(REPLACE "\\" "\\\\" WORKING_DIR_JSON "${WORKING_DIR}")
        string(REPLACE "\\" "\\\\" BUILD_DIR_JSON "${CMAKE_BINARY_DIR}")

        # Parse arguments
        set(ARGS_JSON "")
        if(ARGS)
            string(REPLACE " " ";" ARG_LIST "${ARGS}")
            foreach(ARG ${ARG_LIST})
                if(ARGS_JSON)
                    string(APPEND ARGS_JSON ", ")
                endif()
                string(APPEND ARGS_JSON "\"${ARG}\"")
            endforeach()
        endif()

        # Platform-specific debugger settings
        if(WIN32)
            set(DEBUGGER_TYPE "cppvsdbg")
            set(PLATFORM_CONFIG "\"console\": \"integratedTerminal\"")
        elseif(APPLE)
            set(DEBUGGER_TYPE "cppdbg")
            set(PLATFORM_CONFIG "\"MIMode\": \"lldb\", \"externalConsole\": false")
        else()
            set(DEBUGGER_TYPE "cppdbg")
            set(PLATFORM_CONFIG "\"MIMode\": \"gdb\", \"externalConsole\": false")
        endif()

        # Write launch.json
        file(WRITE "${VSCODE_DIR}/launch.json"
"{
    \"version\": \"0.2.0\",
    \"configurations\": [{
        \"name\": \"Debug ${TARGET}\",
        \"type\": \"${DEBUGGER_TYPE}\",
        \"request\": \"launch\",
        \"program\": \"${PROGRAM_JSON}\",
        \"args\": [${ARGS_JSON}],
        \"stopAtEntry\": false,
        \"cwd\": \"${WORKING_DIR_JSON}\",
        \"environment\": [],
        ${PLATFORM_CONFIG}
    }]
}")

        # Write tasks.json
        file(WRITE "${VSCODE_DIR}/tasks.json"
"{
    \"version\": \"2.0.0\",
    \"tasks\": [{
        \"label\": \"Build ${TARGET}\",
        \"type\": \"shell\",
        \"command\": \"cmake\",
        \"args\": [\"--build\", \"${BUILD_DIR_JSON}\", \"--target\", \"${TARGET}\", \"--config\", \"Release\"],
        \"group\": { \"kind\": \"build\", \"isDefault\": true },
        \"problemMatcher\": \"$msCompile\"
    }]
}")
    endif()
endfunction()

# Public function to add an IDA plugin
function(ida_add_plugin NAME)
    _ida_create_addon_internal(${NAME} "plugin" idasdk::plugin "${IDA_PLUGIN_DIR}" ${ARGN})
endfunction()

# Public function to add an IDA loader
function(ida_add_loader NAME)
    _ida_create_addon_internal(${NAME} "loader" idasdk::loader "${IDA_LOADER_DIR}" ${ARGN})
endfunction()

# Public function to add an IDA processor module
function(ida_add_procmod NAME)
    _ida_create_addon_internal(${NAME} "procmod" idasdk::procmod "${IDA_PROCMOD_DIR}" ${ARGN})
endfunction()

# Function to create an IDALib executable
function(ida_add_idalib_exe NAME)
    cmake_parse_arguments(ARG
        ""
        "OUTPUT_NAME;DEBUG_ARGS;DEBUG_WORKING_DIR"
        "SOURCES;LIBRARIES;INCLUDES;DEFINES"
        ${ARGN}
    )

    # Create the executable
    add_executable(${NAME} ${ARG_SOURCES})

    # Link to base configuration and IDALib (order matters for property inheritance)
    target_link_libraries(${NAME}
        PRIVATE
            ida_addon_base      # Common properties (even though it's an exe, shares config)
            idasdk::idalib      # IDALib target (includes platform/compiler settings)
    )

    # Add user-specified libraries (after SDK to allow overrides)
    if(ARG_LIBRARIES)
        target_link_libraries(${NAME} PRIVATE ${ARG_LIBRARIES})
    endif()

    # Set output name if specified
    if(ARG_OUTPUT_NAME)
        set_target_properties(${NAME} PROPERTIES OUTPUT_NAME ${ARG_OUTPUT_NAME})
    endif()

    # Add user-specified includes (PRIVATE to not leak to dependents)
    if(ARG_INCLUDES)
        target_include_directories(${NAME} PRIVATE ${ARG_INCLUDES})
    endif()

    # Add user-specified defines (PRIVATE to not leak to dependents)
    if(ARG_DEFINES)
        target_compile_definitions(${NAME} PRIVATE ${ARG_DEFINES})
    endif()

    # Debug configuration
    if(ARG_DEBUG_ARGS OR ARG_DEBUG_WORKING_DIR)
        set(DEBUG_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        if(ARG_DEBUG_WORKING_DIR)
            set(DEBUG_DIR ${ARG_DEBUG_WORKING_DIR})
        endif()

        # Visual Studio
        if(MSVC)
            # Convert path to native format for Visual Studio
            file(TO_NATIVE_PATH "${DEBUG_DIR}" DEBUG_DIR_NATIVE)

            set_target_properties(${NAME} PROPERTIES
                VS_DEBUGGER_COMMAND_ARGUMENTS "${ARG_DEBUG_ARGS}"
                VS_DEBUGGER_WORKING_DIRECTORY "${DEBUG_DIR_NATIVE}"
            )
        endif()

        # Generate VS Code launch.json for executable
        _ida_generate_vscode_config(${NAME} "$<TARGET_FILE:${NAME}>" "${ARG_DEBUG_ARGS}" "${DEBUG_DIR}")
    endif()

    # Disable IDA warnings by default
    ida_disable_warnings(${NAME})
endfunction()

