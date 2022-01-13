cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(pdb)

# Included file
list(APPEND DISABLED_SOURCES common.cpp 
	misc.cpp msdia.cpp misc.cpp common.cpp pdblocal.cpp tilbuild.cpp sip.cpp
	pdbremote.cpp
	cvconst.h dbghelp.h dia2.h oldpdb.h)

set(PLUGIN_NAME  pdb)
set(PLUGIN_SOURCES pdb.cpp old.cpp ${DISABLED_SOURCES})

include($ENV{IDASDK}/ida-cmake/plugins.cmake)

set_source_files_properties(${DISABLED_SOURCES} PROPERTIES LANGUAGE "")
