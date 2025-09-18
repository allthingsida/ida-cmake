# IDA CMake - No Bootstrap Approach

This template demonstrates using ida-cmake without directly including `bootstrap.cmake`. This method provides maximum flexibility by allowing ida-cmake to be installed anywhere, completely independent of the IDASDK location.

## Key Benefits

- **Location Independence**: ida-cmake can be installed anywhere on the system
- **Clean CMakeLists.txt**: No hardcoded paths or bootstrap includes
- **Package Manager Friendly**: Works well with system package managers
- **CI/CD Ready**: Perfect for containerized builds and automation

## How It Works

Instead of including `bootstrap.cmake` directly, this approach uses CMake's standard package discovery mechanism:

```cmake
cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

find_package(idasdk REQUIRED)

ida_add_plugin(myplugin
    SOURCES main.cpp
)
```

## Installation Options

### Option 1: Separate Installation (Recommended)

Install ida-cmake anywhere on your system:

```bash
# Clone to any location
git clone https://github.com/allthingsida/ida-cmake.git /opt/ida-cmake

# Or user directory
git clone https://github.com/allthingsida/ida-cmake.git ~/ida-cmake
```

### Option 2: Traditional (Inside IDASDK)

For backward compatibility, you can still install inside IDASDK:

```bash
git clone https://github.com/allthingsida/ida-cmake.git $IDASDK/ida-cmake
```

## Usage

### Build with Separate Installation

Set both `IDASDK` and `CMAKE_PREFIX_PATH`:

```bash
# Set IDASDK to your SDK location
export IDASDK=/path/to/idasdk92

# Build using CMAKE_PREFIX_PATH
cmake -DCMAKE_PREFIX_PATH=/opt/ida-cmake -B build
cmake --build build --config Release
```

### Build with Traditional Installation

Only `IDASDK` is needed:

```bash
export IDASDK=/path/to/idasdk92
cmake -DCMAKE_PREFIX_PATH=$IDASDK/ida-cmake -B build
cmake --build build --config Release
```

## Environment Variables

- `IDASDK` - **Required**: Path to IDA SDK installation
- `IDABIN` - **Optional**: Path to IDA binaries (defaults to `$IDASDK/bin`)

## Complete Example

Here's a complete workflow using the no-bootstrap approach:

```bash
# 1. Set up environment
export IDASDK=/Users/you/idasdk92

# 2. Clone this template
cp -r $IDASDK/ida-cmake/templates/plugin-no-bootstrap my-plugin
cd my-plugin

# 3. Configure and build
cmake -DCMAKE_PREFIX_PATH=$IDASDK/ida-cmake -B build
cmake --build build --config Release

# Your plugin is now at: $IDASDK/bin/plugins/myplugin.dylib
```

## When to Use This Approach

**Use the no-bootstrap approach when:**
- Building in CI/CD environments
- Creating distributable packages
- Working with multiple IDA SDK versions
- Preferring clean, portable CMakeLists.txt files
- Installing ida-cmake system-wide

**Use the traditional bootstrap approach when:**
- Quick prototyping and development
- Following existing project patterns
- Working within a single SDK environment

## Verified Independence

This approach has been tested to confirm that ida-cmake works completely independently of the IDASDK location:

- ✅ IDASDK at: `/tmp/idasdk92-clean` (without ida-cmake)
- ✅ ida-cmake at: `/tmp/ida-cmake-isolated` (completely separate)
- ✅ Plugin builds and deploys successfully

This proves ida-cmake can be packaged, distributed, and installed anywhere without requiring co-location with the IDA SDK.