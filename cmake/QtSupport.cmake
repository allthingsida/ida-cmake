# =================================================================
# Qt Support for IDA SDK
# =================================================================
# Provides Qt6 building and auto-detection for IDA plugins.
#
# Features:
#   - build_qt target: Builds Qt6 from source with QT_NAMESPACE=QT
#   - Auto-detection: Finds Qt6 in ${CMAKE_BINARY_DIR}/qt-install/
#   - Cross-platform: Windows, Linux, macOS
#
# Usage:
#   cmake --build build --target build_qt  # Build Qt (once, ~2 hours)
#   cmake -B build                          # Reconfigure (finds Qt)
#   cmake --build build                     # Build with Qt support
# =================================================================

include(ExternalProject)

# Qt configuration
set(QT_VERSION "6.8.2" CACHE STRING "Qt version to build")
set(QT_SOURCE_URL "https://download.qt.io/archive/qt/6.8/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz")
set(QT_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/qt-install" CACHE PATH "Qt installation directory")

# =================================================================
# Auto-detect existing Qt installation
# =================================================================

if(EXISTS "${QT_INSTALL_PREFIX}/lib/cmake/Qt6")
    set(Qt6_DIR "${QT_INSTALL_PREFIX}/lib/cmake/Qt6" CACHE PATH "Qt6 CMake directory" FORCE)
    message(STATUS "Found IDA-built Qt6 at: ${Qt6_DIR}")
endif()

# =================================================================
# build_qt target: Build Qt6 from source
# =================================================================

# Platform-specific Qt configure options
if(WIN32)
    set(QT_PLATFORM_OPTS
        -DCMAKE_C_COMPILER=cl
        -DCMAKE_CXX_COMPILER=cl
        -DQT_QMAKE_TARGET_MKSPEC=win32-msvc
    )
elseif(APPLE)
    set(QT_PLATFORM_OPTS
        -DCMAKE_OSX_ARCHITECTURES=x86_64$<SEMICOLON>arm64  # Universal binary
        -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15
    )
else()
    set(QT_PLATFORM_OPTS
        # Linux defaults
    )
endif()

# Qt configure arguments
# Build only essential modules for IDA plugins (qtbase only)
set(QT_CONFIGURE_ARGS
    -DQT_BUILD_EXAMPLES=OFF
    -DQT_BUILD_TESTS=OFF
    -DQT_NAMESPACE=QT                    # IDA requirement!
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=${QT_INSTALL_PREFIX}

    # Build only qtbase module (Core, Gui, Widgets, OpenGL)
    -DQT_BUILD_SUBMODULES=qtbase

    # Essential features for IDA plugins
    -DFEATURE_gui=ON
    -DFEATURE_widgets=ON
    -DFEATURE_opengl=ON

    # Disable unneeded features
    -DFEATURE_network=OFF                # Not needed for IDA plugins
    -DFEATURE_sql=OFF
    -DFEATURE_dbus=OFF
    -DFEATURE_concurrent=OFF
    -DFEATURE_printsupport=OFF
    -DQT_FEATURE_animation=OFF
    -DQT_FEATURE_pdf=OFF
    -DQT_FEATURE_assistant=OFF
    ${QT_PLATFORM_OPTS}
)

# Create initial cache file to completely block vcpkg
set(QT_INITIAL_CACHE_FILE "${CMAKE_BINARY_DIR}/qt-initial-cache.cmake")
file(WRITE "${QT_INITIAL_CACHE_FILE}" "
# Block vcpkg completely
unset(CMAKE_TOOLCHAIN_FILE CACHE)
unset(VCPKG_TARGET_TRIPLET CACHE)
unset(VCPKG_INSTALLED_DIR CACHE)
unset(VCPKG_MANIFEST_MODE CACHE)
unset(Z_VCPKG_ROOT_DIR CACHE)

# Explicitly set compilers
set(CMAKE_C_COMPILER \"${CMAKE_C_COMPILER}\" CACHE FILEPATH \"C compiler\" FORCE)
set(CMAKE_CXX_COMPILER \"${CMAKE_CXX_COMPILER}\" CACHE FILEPATH \"CXX compiler\" FORCE)
")

ExternalProject_Add(qt6_external
    PREFIX "${CMAKE_BINARY_DIR}/qt-prefix"
    URL ${QT_SOURCE_URL}
    URL_HASH SHA256=659d8bb5931afac9ed5d89a78e868e6bd00465a58ab566e2123db02d674be559  # Qt 6.8.2 hash (verified)
    SOURCE_DIR "${CMAKE_BINARY_DIR}/qt-src"
    BINARY_DIR "${CMAKE_BINARY_DIR}/qt-build"

    CMAKE_GENERATOR Ninja  # Qt requires Ninja on Windows for proper config tests
    CMAKE_CACHE_ARGS
        -C${QT_INITIAL_CACHE_FILE}  # Load initial cache to block vcpkg
    CMAKE_ARGS
        ${QT_CONFIGURE_ARGS}

    BUILD_COMMAND ${CMAKE_COMMAND} --build . --config Release --parallel
    INSTALL_COMMAND ${CMAKE_COMMAND} --install . --config Release

    EXCLUDE_FROM_ALL TRUE
    STEP_TARGETS download configure build install
)

# Custom target for user-friendly invocation
add_custom_target(build_qt
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target qt6_external
    COMMAND ${CMAKE_COMMAND} -E echo "========================================"
    COMMAND ${CMAKE_COMMAND} -E echo "Qt6 built successfully!"
    COMMAND ${CMAKE_COMMAND} -E echo "Installed to: ${QT_INSTALL_PREFIX}"
    COMMAND ${CMAKE_COMMAND} -E echo "========================================"
    COMMAND ${CMAKE_COMMAND} -E echo "Reconfiguring to detect Qt..."
    COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} -B ${CMAKE_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E echo "========================================"
    COMMAND ${CMAKE_COMMAND} -E echo "Ready! Run: cmake --build ${CMAKE_BINARY_DIR}"
    COMMAND ${CMAKE_COMMAND} -E echo "========================================"
    COMMENT "Building Qt6 with QT_NAMESPACE=QT (this will take 1-2 hours)..."
    VERBATIM
)

# Help message
if(NOT Qt6_FOUND AND NOT TARGET Qt6::Core)
    message(STATUS "================================================================")
    message(STATUS "Qt6 not found. To build Qt plugins (qproject, qwindow):")
    message(STATUS "  cmake --build ${CMAKE_BINARY_DIR} --target build_qt")
    message(STATUS "================================================================")
endif()
