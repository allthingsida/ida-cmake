# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ida-cmake is a CMake build system for developing IDA Pro addons (plugins, loaders, processor modules, and idalib applications) using the IDA SDK. It provides a clean interface library approach with automatic IDE configuration and cross-platform support.

## Environment Setup

Two environment variables are required:
- `IDASDK`: Path to IDA SDK installation (e.g., `C:\idasdk92` on Windows)
- `IDABIN`: (Optional) Path to IDA binaries, defaults to `$IDASDK/bin`

## Common Commands

### Building Projects
```bash
# Standard build
cmake -B build
cmake --build build --config Release

# Debug build
cmake -DCMAKE_BUILD_TYPE=Debug -B build
cmake --build build

# Clean rebuild
cmake --build build --target clean
cmake --build build
```

### Creating New Addons
Use the provided CMake functions in any project's CMakeLists.txt:
- `ida_add_plugin()` - Create IDA plugin
- `ida_add_loader()` - Create file loader
- `ida_add_procmod()` - Create processor module
- `ida_add_idalib()` - Create standalone idalib application

### Testing
- Built addons are automatically deployed to `$IDABIN/plugins/`, `$IDABIN/loaders/`, or `$IDABIN/procs/`
- Use sample IDB files from `samples/` for testing
- Debug configurations are auto-generated for VS Code, Visual Studio, and CLion

## Architecture

### Core Components
- **bootstrap.cmake**: Entry point that validates environment and includes all modules
- **idasdkConfig.cmake**: Main package configuration with interface targets
- **cmake/targets.cmake**: Functions for creating addon targets
- **cmake/platform.cmake**: Platform/architecture detection
- **cmake/compiler.cmake**: Compiler-specific settings

### Interface Targets
The system provides clean interface libraries:
- `idasdk::plugin` - For IDA plugins
- `idasdk::loader` - For file loaders
- `idasdk::procmod` - For processor modules
- `idasdk::idalib` - For standalone applications

All targets automatically inherit platform settings, compiler flags, and SDK dependencies.

## Development Workflow

1. Set `IDASDK` environment variable to SDK path
2. Include bootstrap.cmake in project CMakeLists.txt
3. Use `find_package(idasdk REQUIRED)`
4. Add addons with `ida_add_*` functions
5. Build normally with CMake

Templates are provided in `/templates/` for each addon type with working examples.

## Important Notes

- Minimum CMake version: 3.27
- Supported IDA SDK: 9.0+
- All platforms build with EA64 (64-bit addressing)
- Compiler warnings from IDA SDK headers are automatically suppressed
- Debug builds include sanitizers and enhanced debugging on supported platforms