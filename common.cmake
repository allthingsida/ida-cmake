include_guard(DIRECTORY)

# Specify the addressing mode for the addons
set(EA64   OFF  CACHE BOOL     "64-bits addressing")

# Specify the default MAXSTR string buffer size
set(MAXSTR 1024 CACHE STRING   "MAXSTR value")

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
file(TO_NATIVE_PATH ${IDABIN} IDABIN)

# Set libraries path
if (WIN32 AND MSVC)
    set(__NT__ 1)
    set(IDALIBPATH32  "${IDASDK}/lib/x64_win_vc_32")
    set(IDALIBPATH64  "${IDASDK}/lib/x64_win_vc_64")
    set(IDASLIBPATH32 "${IDASDK}/lib/x86_win_vc_32_s")
    set(IDASLIBPATH64 "${IDASDK}/lib/x64_win_vc_64_s")

    set(IDALIB32 ${IDALIBPATH32}/ida.lib)
    set(IDALIB64 ${IDALIBPATH64}/ida.lib)
    if (${EA64})
        set(IDAEXE ida64.exe)
    else()
        set(IDAEXE ida.exe)
    endif()
elseif(APPLE)
    set(__MAC__ 1)
    if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm64")
        set(IDALIBPATH32 ${IDASDK}/lib/arm64_mac_clang_32)
        set(IDALIBPATH64 ${IDASDK}/lib/arm64_mac_clang_64)
    else()
        set(IDALIBPATH32 ${IDASDK}/lib/x64_mac_clang_32)
        set(IDALIBPATH64 ${IDASDK}/lib/x64_mac_clang_64)
    endif()
    set(IDALIB32 ${IDALIBPATH32}/libida.dylib)
    set(IDALIB64 ${IDALIBPATH64}/libida64.dylib)
elseif(UNIX AND NOT APPLE)
    set(__LINUX__ 1)
    set(IDALIBPATH32  "${IDASDK}/lib/x64_linux_gcc_32")
    set(IDALIBPATH64  "${IDASDK}/lib/x64_linux_gcc_64")
    set(IDASLIBPATH64 "${IDALIBPATH64}")

    set(IDALIB32 ${IDALIBPATH32}/libida.so)
    set(IDALIB64 ${IDALIBPATH64}/libida64.so)
else()
    message(FATAL "Unknown platform!")
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

set(IDALIBSUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
set(IDAPROLIB "${IDASLIBPATH}/pro${IDALIBSUFFIX}")