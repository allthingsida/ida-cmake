cmake_minimum_required(VERSION 3.20)

project(myidalib VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include($ENV{IDASDK}/ida-cmake/idasdk.cmake)

# Add the executable
add_executable(myidalib main.cpp)
target_link_libraries(myidalib PRIVATE ${IDALIBLIB} ${IDALIB})
target_include_directories(myidalib PRIVATE ${IDAPROINCLUDE})
target_compile_definitions(myidalib PRIVATE ${IDAPROPLAT}=1 ${IDAEA64})