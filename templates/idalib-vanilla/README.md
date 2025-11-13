# IDALib Template - Vanilla CMake Approach

This template demonstrates building IDA Pro standalone applications (using IDA as a library) with standard CMake commands.

## Overview

Unlike the convenience function approach (`ida_add_idalib()`), this template uses vanilla CMake commands:
- `add_executable()` to create the application
- `target_link_libraries()` to link with `idasdk::idalib`
- Manual configuration of runtime paths and platform settings

## When to Use This Approach

Choose the vanilla CMake approach when you:
- Want explicit control over all build settings
- Are integrating IDA analysis into existing CMake projects
- Need custom runtime path configurations
- Prefer standard CMake patterns over convenience functions

## What You Need to Handle Manually

When using vanilla CMake instead of `ida_add_idalib()`, you must configure:

1. **Runtime paths** - RPATH settings for finding IDA's shared libraries
2. **Platform settings** - PATH environment (Windows), RPATH (Unix/macOS)
3. **Output directories** - Where to place the built executable
4. **Debug configuration** - Debugger environment and arguments

## The Interface Target

The `idasdk::idalib` interface target automatically provides:
- Include directories (`$IDASDK/include`)
- Compile definitions (`__EA64__`, platform macros)
- IDA library dependencies (`ida.lib`/`libida.dylib`/`libida.so`)
- Required compiler flags

## Building

```bash
# Configure
cmake -B build

# Build
cmake --build build --config Release

# Run the executable
./build/bin/myidalib path/to/database.idb
```

## Runtime Requirements

### Windows
The IDA binary directory must be in the PATH. The template handles this for debugging, but for deployment you need to either:
- Copy IDA DLLs to your executable directory
- Add `$IDABIN` to system PATH
- Use a wrapper script to set PATH

### macOS/Linux
The template sets RPATH to find IDA libraries. The executable will search:
- Its own directory
- The IDA binary directory (`$IDABIN`)

## Customization Examples

### Adding External Libraries

```cmake
find_package(Boost REQUIRED COMPONENTS filesystem system)
target_link_libraries(myidalib PRIVATE
    idasdk::idalib
    Boost::filesystem
    Boost::system
)
```

### Multiple Source Files

```cmake
add_executable(myidalib
    main.cpp
    analysis.cpp
    utils.cpp
)
target_link_libraries(myidalib PRIVATE idasdk::idalib)
```

### Custom Output Location

```cmake
set_target_properties(myidalib PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/output"
)
```

### Static Linking (if available)

```cmake
set_target_properties(myidalib PROPERTIES
    LINK_SEARCH_START_STATIC ON
    LINK_SEARCH_END_STATIC ON
)
```

## Comparison with Convenience Function

The convenience function approach:
```cmake
ida_add_idalib(myidalib SOURCES main.cpp)
```

Is equivalent to this vanilla CMake code:
```cmake
add_executable(myidalib main.cpp)
target_link_libraries(myidalib PRIVATE idasdk::idalib)

# Platform-specific runtime configuration
if(WIN32)
    if(MSVC)
        file(TO_NATIVE_PATH "${IDABIN}" IDABIN_NATIVE)
        set_target_properties(myidalib PROPERTIES
            VS_DEBUGGER_ENVIRONMENT "PATH=${IDABIN_NATIVE};%PATH%"
        )
    endif()
    target_link_options(myidalib PRIVATE /SUBSYSTEM:CONSOLE)
elseif(APPLE)
    set_target_properties(myidalib PROPERTIES
        INSTALL_RPATH "@loader_path;${IDABIN}"
        BUILD_WITH_INSTALL_RPATH TRUE
    )
elseif(UNIX)
    set_target_properties(myidalib PROPERTIES
        INSTALL_RPATH "$ORIGIN:${IDABIN}"
        BUILD_WITH_INSTALL_RPATH TRUE
    )
endif()

ida_disable_warnings(myidalib)
```

## Example Application

The included `main.cpp` demonstrates:
- Initializing the IDA library
- Opening an IDA database
- Running auto-analysis
- Enumerating segments and functions
- Accessing database information
- Proper cleanup

## See Also

- Main ida-cmake documentation: [README.md](../../README.md)
- Convenience function template: [templates/idalib/](../idalib/)
- IDA SDK documentation: `$IDASDK/doc/`