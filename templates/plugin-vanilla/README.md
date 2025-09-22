# IDA Plugin Template - Vanilla CMake Approach

This template demonstrates building IDA Pro plugins using standard CMake commands with ida-cmake's interface targets.

## Overview

Unlike the convenience function approach (`ida_add_plugin()`), this template uses vanilla CMake commands:
- `add_library()` to create the plugin
- `target_link_libraries()` to link with `idasdk::plugin`
- Manual configuration of platform-specific settings

## When to Use This Approach

Choose the vanilla CMake approach when you:
- Prefer explicit control over all build settings
- Have complex build requirements that need fine-tuning
- Are integrating with existing CMake projects
- Want to understand exactly what's happening under the hood

## What You Need to Handle Manually

When using vanilla CMake instead of `ida_add_plugin()`, you must configure:

1. **Output directories** - Set where the plugin is deployed
2. **Platform settings** - Remove "lib" prefix on Unix, set Windows subsystem
3. **Warning suppression** - Optional but recommended for SDK headers
4. **Debug configuration** - Set up debugger paths and arguments

## The Interface Target

The `idasdk::plugin` interface target automatically provides:
- Include directories (`$IDASDK/include`)
- Compile definitions (`__IDP__`, `__EA64__`, platform macros)
- Compiler flags (optimization, debug symbols, PIC)
- IDA library dependencies
- Platform-specific settings

## Building

```bash
# Configure
cmake -B build

# Build
cmake --build build --config Release

# Your plugin will be in $IDABIN/plugins/
```

## Customization Examples

### Adding External Libraries

```cmake
find_package(Boost REQUIRED COMPONENTS filesystem)
target_link_libraries(myplugin PRIVATE
    idasdk::plugin
    Boost::filesystem
)
```

### Multiple Source Files

```cmake
add_library(myplugin SHARED
    main.cpp
    utils.cpp
    analysis.cpp
)
target_link_libraries(myplugin PRIVATE idasdk::plugin)
```

### Custom Output Name

```cmake
set_target_properties(myplugin PROPERTIES
    OUTPUT_NAME "my_custom_plugin_name"
)
```

## Comparison with Convenience Function

The convenience function approach:
```cmake
ida_add_plugin(myplugin SOURCES main.cpp)
```

Is equivalent to this vanilla CMake code:
```cmake
add_library(myplugin SHARED main.cpp)
target_link_libraries(myplugin PRIVATE idasdk::plugin)
set_target_properties(myplugin PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${IDABIN}/plugins"
    LIBRARY_OUTPUT_DIRECTORY "${IDABIN}/plugins"
)
if(UNIX)
    set_target_properties(myplugin PROPERTIES PREFIX "")
endif()
if(WIN32)
    target_link_options(myplugin PRIVATE /SUBSYSTEM:WINDOWS)
endif()
ida_disable_warnings(myplugin)
```

## See Also

- Main ida-cmake documentation: [README.md](../../README.md)
- Convenience function template: [templates/plugin/](../plugin/)
- Other addon types: [templates/](../)