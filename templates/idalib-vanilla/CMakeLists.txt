cmake_minimum_required(VERSION 3.27)
project(myidalib VERSION 1.0)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Standard CMake approach - create an executable
add_executable(myidalib main.cpp)

# Link against IDA SDK idalib interface target
# This provides all includes, definitions, and the IDA library
target_link_libraries(myidalib PRIVATE idasdk::idalib)

# Set output directory for the executable
set_target_properties(myidalib PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Platform-specific settings for idalib applications
if(WIN32)
    # Windows needs the IDA binary directory in PATH
    file(TO_NATIVE_PATH "${IDABIN}" IDABIN_NATIVE)

    # For Visual Studio debugging
    if(MSVC)
        set_target_properties(myidalib PROPERTIES
            VS_DEBUGGER_ENVIRONMENT "PATH=${IDABIN_NATIVE};%PATH%"
            VS_DEBUGGER_COMMAND_ARGUMENTS "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64"
        )
    endif()

    # Set subsystem to console for command-line applications
    target_link_options(myidalib PRIVATE /SUBSYSTEM:CONSOLE)
elseif(APPLE)
    # macOS needs RPATH for finding libida.dylib
    set_target_properties(myidalib PROPERTIES
        INSTALL_RPATH "@loader_path;${IDABIN}"
        BUILD_WITH_INSTALL_RPATH TRUE
    )
elseif(UNIX)
    # Linux needs RPATH for finding libida.so
    set_target_properties(myidalib PROPERTIES
        INSTALL_RPATH "$ORIGIN:${IDABIN}"
        BUILD_WITH_INSTALL_RPATH TRUE
    )
endif()

# Optional: Suppress warnings from IDA SDK headers
ida_disable_warnings(myidalib)

# Optional: Configure debugging arguments for all generators
set_property(TARGET myidalib PROPERTY
    VS_DEBUGGER_COMMAND_ARGUMENTS "${IDA_CMAKE_DIR}/samples/wizmo32.exe.i64"
)

# Optional: Add custom libraries, includes, or defines
# find_package(Boost REQUIRED COMPONENTS filesystem)
# target_link_libraries(myidalib PRIVATE Boost::filesystem)
# target_include_directories(myidalib PRIVATE ${CMAKE_SOURCE_DIR}/include)
# target_compile_definitions(myidalib PRIVATE MY_DEBUG=1)

# Note: Unlike plugins, idalib executables can be placed anywhere
# They just need access to IDA's shared libraries at runtime