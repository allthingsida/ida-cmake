include_guard(DIRECTORY)

# Specify the addressing mode for the addons
set(EA64   OFF  CACHE BOOL     "64-bits addressing")

# Specify the default MAXSTR string buffer size (obsolete)
set(MAXSTR 1024 CACHE STRING   "MAXSTR value")

# Set and verify the SDK folder
if (DEFINED IDASDK)
    set(IDASDK ${IDASDK} CACHE STRING "IDASDK location (via -D switch)")
elseif (DEFINED ENV{IDASDK})
    set(IDASDK $ENV{IDASDK} CACHE STRING "IDASDK (environment variable)")
else()
    message(FATAL_ERROR "IDA SDK folder not specified via the -D switch or the environment variable 'IDASDK'")
endif()

file(TO_NATIVE_PATH "${IDASDK}/include/pro.h" IDASDK_PRO_H)

if (NOT EXISTS "${IDASDK_PRO_H}")
    message(FATAL_ERROR "IDA SDK folder '${IDASDK}' seems invalid")
endif()

# Set and verify the IDA installation folder
if (DEFINED IDABIN)
    set(IDABIN ${IDABIN} CACHE STRING "IDA installation location")
    message("-- Setting IDABIN folder to: ${IDABIN}")
elseif (DEFINED ENV{IDABIN})
    set(IDABIN $ENV{IDABIN} CACHE STRING "IDA installation location (environment variable)")
else()
    # Default IDA binary folder is in the SDK's bin folder
    set(IDABIN ${IDASDK}/bin)
    file(TO_NATIVE_PATH ${IDABIN} IDABIN)
    message("-- Setting default IDABIN folder to: ${IDABIN}")
endif()

# Detect the Pro SDK edition (using folder names). We can also check 'defaults.mk'/NOTEAMS=1, etc.
# (The _pro suffix is new since SDK 8.2sp1 pro edition. The Teams SDK does not seem to use any suffix)
file(GLOB FOLDERS "${IDASDK}/lib/*")
foreach (folder ${FOLDERS})
    if (folder MATCHES ".*_pro$")
        set(IDALIBPATHSUFFIX "_pro")
        break()
    endif()
endforeach()

# Parse SDK version
file(READ "${IDASDK_PRO_H}" IDASDK_PRO_H_CONTENT)
string(REGEX MATCH "IDA_SDK_VERSION *([0-9]+)" IDASDK_VERSION "${IDASDK_PRO_H_CONTENT}")
set(IDASDK_VERSION ${CMAKE_MATCH_1})

if ("${IDASDK_VERSION}" STREQUAL "")
    set(IDASDK_VERSION "unknown")
endif()

message("-- Detected IDA SDK version: ${IDASDK_VERSION}")

# Set libraries path
if (WIN32 AND MSVC)
    set(__NT__ 1)
    set(IDALIBSUFFIX "lib")

    set(IDALIBPATH32  "${IDASDK}/lib/x64_win_vc_32${IDALIBPATHSUFFIX}")
    set(IDALIBPATH64  "${IDASDK}/lib/x64_win_vc_64${IDALIBPATHSUFFIX}")
    set(IDASLIBPATH32 "${IDASDK}/lib/x86_win_vc_32${IDALIBPATHSUFFIX}_s")
    set(IDASLIBPATH64 "${IDASDK}/lib/x64_win_vc_64${IDALIBPATHSUFFIX}_s")

    set(IDALIB32 ${IDALIBPATH32}/ida.lib)
    set(IDALIB64 ${IDALIBPATH64}/ida.lib)
    if (${EA64})
        set(IDAEXE ida64.exe)
    else()
        set(IDAEXE ida.exe)
    endif()
elseif(APPLE)
    set(__MAC__ 1)
    set(IDALIBSUFFIX "dylib")

    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm64")
        set(IDALIBPATH32 "${IDASDK}/lib/arm64_mac_clang_32${IDALIBPATHSUFFIX}")
        set(IDALIBPATH64 "${IDASDK}/lib/arm64_mac_clang_64${IDALIBPATHSUFFIX}")
    else()
        set(IDALIBPATH32 "${IDASDK}/lib/x64_mac_clang_32${IDALIBPATHSUFFIX}")
        set(IDALIBPATH64 "${IDASDK}/lib/x64_mac_clang_64${IDALIBPATHSUFFIX}")
    endif()
    set(IDALIB32 ${IDALIBPATH32}/libida.dylib)
    set(IDALIB64 ${IDALIBPATH64}/libida64.dylib)
elseif(UNIX AND NOT APPLE)
    set(__LINUX__ 1)
    set(IDALIBSUFFIX "so")

    set(IDALIBPATH32  "${IDASDK}/lib/x64_linux_gcc_32${IDALIBPATHSUFFIX}")
    set(IDALIBPATH64  "${IDASDK}/lib/x64_linux_gcc_64${IDALIBPATHSUFFIX}")
    set(IDASLIBPATH64 "${IDALIBPATH64}")

    set(IDALIB32 ${IDALIBPATH32}/libida.so)
    set(IDALIB64 ${IDALIBPATH64}/libida64.so)
else()
    message(FATAL_ERROR "Unknown platform!")
endif()

if (${EA64})
    set(IDALIBPATH  "${IDALIBPATH64}")
    set(IDASLIBPATH "${IDASLIBPATH64}")
    set(IDALIB      "${IDALIB64}")
else()
    set(IDALIBPATH  "${IDALIBPATH32}")
    set(IDASLIBPATH "${IDASLIBPATH32}")
    set(IDALIB      "${IDALIB32}")
endif()

set(IDAPROLIB "${IDASLIBPATH}/pro.${IDALIBSUFFIX}")

# Convenience macro to include the addons script and create the proper targets
# The addons script can be included many times, each time it generates a new target
macro(generate)
    if (DEFINED IDASDK)
        include(${IDASDK}/ida-cmake/addons.cmake)
    elseif (DEFINED ENV{IDASDK})
        include($ENV{IDASDK}/ida-cmake/addons.cmake)
    else()
        message(FATAL_ERROR "IDA SDK folder not specified via the -D switch or the environment variable 'IDASDK'")
    endif()
endmacro()

# For MSVC, disable some common IDA compilation warnings
function(disable_ida_warnings target)
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        target_compile_options(${target} PRIVATE "/wd4267" "/wd4244" "/wd4018" "/wd4146")
    endif()
endfunction()

