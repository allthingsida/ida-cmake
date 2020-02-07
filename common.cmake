# Specify the addressing mode for the addons
set(EA64   OFF  CACHE BOOL     "64bit addressing")

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
    set(IDALIB32 ${IDASDK}/lib/x64_win_vc_32/ida.lib)
    set(IDALIB64 ${IDASDK}/lib/x64_win_vc_64/ida.lib)
    if (${EA64})
        set(IDAEXE ida64.exe)
    else()
        set(IDAEXE ida.exe)
    endif()
elseif(APPLE)
    set(__MAC__ 1)
    set(IDALIB32 ${IDASDK}/lib/x64_mac_gcc_32/libida.dylib)
    set(IDALIB64 ${IDASDK}/lib/x64_mac_gcc_64/libida64.dylib)
elseif(UNIX AND NOT APPLE)
    set(__LINUX__ 1)
    set(IDALIB32 ${IDASDK}/lib/x64_linux_gcc_32/libida.so)
    set(IDALIB64 ${IDASDK}/lib/x64_linux_gcc_64/libida64.so)
else()
    message(FATAL "Unknown platform!")
endif()
