# agent.cmake - Agent installation for ida-cmake

# Check if running in script mode (cmake -P)
if(CMAKE_SCRIPT_MODE_FILE)
    # Script mode - perform the actual installation
    if(NOT DEFINED PROJECT_DIR)
        message(FATAL_ERROR "PROJECT_DIR not defined")
    endif()

    # Get IDASDK from environment if not passed
    if(NOT DEFINED IDASDK)
        set(IDASDK "$ENV{IDASDK}")
    endif()
    if(NOT IDASDK)
        message(FATAL_ERROR "IDASDK not defined")
    endif()

    # Find ida-cmake directory
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/../.claude/agents/ida-cmake.md")
        set(IDA_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
    else()
        message(FATAL_ERROR "ida-cmake agent not found. Ensure ida-cmake is properly installed.")
    endif()

    # Install agent file
    set(AGENT_PATH "${PROJECT_DIR}/.claude/agents/ida-cmake.md")
    if(NOT EXISTS "${AGENT_PATH}")
        file(MAKE_DIRECTORY "${PROJECT_DIR}/.claude/agents")
        configure_file("${IDA_CMAKE_DIR}/.claude/agents/ida-cmake.md" "${AGENT_PATH}" COPYONLY)
        message(STATUS "Agent installed to: ${AGENT_PATH}")
    endif()

    # Install CLAUDE.md
    set(CLAUDE_MD_PATH "${PROJECT_DIR}/CLAUDE.md")
    if(NOT EXISTS "${CLAUDE_MD_PATH}")
        if(NOT DEFINED ADDON_NAME)
            get_filename_component(ADDON_NAME "${PROJECT_DIR}" NAME)
        endif()
        configure_file("${IDA_CMAKE_DIR}/templates/CLAUDE.md" "${CLAUDE_MD_PATH}" @ONLY)
        message(STATUS "CLAUDE.md created with addon name: ${ADDON_NAME}")
    endif()

    return()
endif()

# Normal include mode - create installation target
include_guard(DIRECTORY)

if(NOT TARGET install_idacmake_agent)
    # Detect addon name from project
    if(DEFINED PROJECT_NAME)
        set(DETECTED_ADDON_NAME "${PROJECT_NAME}")
    else()
        get_filename_component(DETECTED_ADDON_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
    endif()

    add_custom_target(install_idacmake_agent
        COMMAND ${CMAKE_COMMAND}
            -D PROJECT_DIR=${CMAKE_CURRENT_SOURCE_DIR}
            -D ADDON_NAME="${DETECTED_ADDON_NAME}"
            -D IDASDK=${IDASDK}
            -P "${CMAKE_CURRENT_LIST_FILE}"
        COMMENT "Installing ida-cmake build agent"
        VERBATIM
    )

    # Only show installation message if agent is not already installed
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.claude/agents/ida-cmake.md")
        message(STATUS "To install the ida-cmake build agent, run: cmake --build build --target install_idacmake_agent")
    endif()
endif()