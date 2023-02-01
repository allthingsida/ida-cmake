cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(pdb)

set(CMAKE_CXX_STANDARD 17)

include($ENV{IDASDK}/ida-cmake/common.cmake)

# Included file
list(APPEND DISABLED_SOURCES common.cpp pdblocal.cpp 
							 misc.cpp misc.cpp
							 msdia.cpp tilbuild.cpp
					         pdbremote.cpp sip.cpp
							 cvconst.h dbghelp.h dia2.h oldpdb.h)

set(PLUGIN_NAME  pdb)
set(PLUGIN_SOURCES pdb.cpp old.cpp ${DISABLED_SOURCES})

generate()

set_source_files_properties(${DISABLED_SOURCES} PROPERTIES LANGUAGE "")
