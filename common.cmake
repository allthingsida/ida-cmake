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

# Detect Pro SDK edition (using folder names). We can also check 'defaults.mk'/NOTEAMS=1, etc.
# (The _pro suffix is new since SDK 8.2sp1 pro edition. The Teams SDK does not seem to use any suffix)
file(GLOB FOLDERS "${IDASDK}/lib/*")
foreach (folder ${FOLDERS})
    if (folder MATCHES ".*_pro$")
        set(IDALIBPATHSUFFIX "_pro")
        break()
    endif()
endforeach()

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

set(IDAPROLIB "${IDASLIBPATH}/pro.${IDALIBSUFFIX}")

