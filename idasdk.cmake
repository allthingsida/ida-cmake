include_guard(DIRECTORY)
if (DEFINED IDASDK)
    include(${IDASDK}/ida-cmake/common.cmake)
elseif (DEFINED ENV{IDASDK})
    include($ENV{IDASDK}/ida-cmake/common.cmake)
else()
    message(FATAL_ERROR "IDA SDK folder not specified via the -D switch or the environment variable 'IDASDK'")
endif()
