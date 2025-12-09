# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ida-cmake is a CMake build system for developing IDA Pro addons (plugins, loaders, processor modules, and standalone idalib applications) using the IDA SDK 9.2+.

## Build Commands

```bash
# Configure and build (from any template or project using ida-cmake)
cmake -B build
cmake --build build --config Release

# Build with specific configuration
cmake --build build --config RelWithDebInfo

# Build Qt support (one-time, ~1-2 hours)
cmake --build build --target build_qt

# Install Claude agent to a project
cmake --build build --target install_idacmake_agent
```

## Environment Setup

Required environment variable:
- `IDASDK` - Path to IDA SDK directory (e.g., `C:\idasdk92` or `/path/to/idasdk92`)

Optional:
- `IDABIN` - Path to IDA installation (defaults to `$IDASDK/bin`)

## Architecture

### CMake Module Structure

```
bootstrap.cmake          # Entry point: sets CMAKE_PREFIX_PATH, auto-detects GitHub vs zip SDK structure
idasdkConfig.cmake       # Package config: creates interface targets, handles universal binaries
cmake/
├── platform.cmake       # Platform detection (Windows/Linux/macOS), library paths
├── compiler.cmake       # Compiler settings (MSVC/GCC/Clang), warning suppression
├── targets.cmake        # ida_add_plugin(), ida_add_loader(), ida_add_procmod(), ida_add_idalib()
├── utilities.cmake      # SDK version detection, environment validation
├── QtSupport.cmake      # Qt 6.8.2 building and detection
└── agent.cmake          # Claude agent installation target
```

### Interface Targets

- `idasdk::plugin` - For IDA plugins (defines `__IDP__`)
- `idasdk::loader` - For file loaders (defines `__LOADER__`, includes `ldr/`)
- `idasdk::procmod` - For processor modules (includes `module/`)
- `idasdk::idalib` - For standalone applications using IDA as library (defines `IDALIB_IMPL`)

All targets automatically handle: includes, defines, platform settings, compiler flags, and library linking.

### Convenience Functions

```cmake
ida_add_plugin(name SOURCES ... [LIBRARIES ...] [INCLUDES ...] [DEFINES ...] [METADATA_JSON ...])
ida_add_loader(name SOURCES ...)
ida_add_procmod(name SOURCES ...)
ida_add_idalib(name SOURCES ... [TYPE EXECUTABLE|SHARED|STATIC])
```

### Templates

Located in `templates/`:
- `plugin/` - Basic plugin (convenience functions)
- `plugin-pch/` - Plugin with precompiled headers
- `plugin-vanilla/` - Plugin using standard CMake
- `plugin-no-bootstrap/` - Plugin using CMAKE_PREFIX_PATH approach
- `loader/` - File loader
- `procmod/` - Processor module
- `idalib/` - Standalone idalib application
- `idalib-vanilla/` - idalib using standard CMake

## Key Design Decisions

1. **64-bit only**: Always uses EA64 (`__EA64__` defined)
2. **C++17 required**: Set via `ida_addon_base` interface library
3. **Auto-deployment**: Addons are automatically copied to `$IDABIN/plugins/`, `loaders/`, or `procs/`
4. **Warning suppression**: IDA SDK warnings are suppressed via `ida_disable_warnings()`
5. **macOS universal binaries**: Automatic `lipo` merging when `CMAKE_OSX_ARCHITECTURES` includes multiple architectures

## Plugin Metadata (IDA 9.x)

Optional `ida-plugin.json` support for IDA 9.0+ plugin organization:
```cmake
ida_add_plugin(myplugin
    SOURCES main.cpp
    METADATA_JSON ida-plugin.json  # Deploys to plugins/myplugin/ subfolder
)
```

If the JSON file doesn't exist, ida-cmake generates a template automatically.
