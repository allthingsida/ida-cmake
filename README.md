# ida-cmake - CMake Build System for the IDA SDK

CMake build system for developing IDA Pro addons (plugins, loaders, processor modules and standalone idalib apps) using the IDA SDK.

>For IDA 9.1 and below, please check the [9.1](https://github.com/allthingsida/ida-cmake/tree/9.1) branch.

## Quick Start

### 1. Prerequisites

- CMake 3.27 or later
- IDA SDK 9.2+ (set `IDASDK` environment variable)
- Visual Studio 2022 (Windows) / GCC/Clang (Linux/macOS)

### 2. Setup

<u>Windows</u>

```batch
# Set environment variable (Windows)
set IDASDK=C:\idasdk92
git clone https://github.com/allthingsida/ida-cmake.git %IDASDK%/ida-cmake
```

<u>Linux/macOS</u>

```bash
# Set environment variable (Linux/macOS)
export IDASDK=/path/to/idasdk92

# Clone ida-cmake into your SDK folder
git clone https://github.com/allthingsida/ida-cmake.git $IDASDK/ida-cmake
```

> **Alternative:** For advanced users who prefer not to include bootstrap.cmake directly, see [`templates/plugin-no-bootstrap/`](templates/plugin-no-bootstrap/) for the `CMAKE_PREFIX_PATH` approach that allows ida-cmake to be installed anywhere.

### 3. Create Your First Plugin

Create a `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Add plugin
ida_add_plugin(myplugin
    SOURCES main.cpp
)
```

Build it:

```bash
cmake -B build
cmake --build build --config Release
```

Your plugin will be automatically deployed to `$IDABIN/plugins/`.

## API Reference

### Core Functions

#### `ida_add_plugin(name ...)`
Creates an IDA plugin target.

```cmake
ida_add_plugin(myplugin
    SOURCES main.cpp utils.cpp
    LIBRARIES Boost::filesystem  # Optional: additional libraries
    INCLUDES ${CMAKE_SOURCE_DIR}/include  # Optional: additional includes
    DEFINES MY_DEBUG=1  # Optional: preprocessor definitions
    OUTPUT_NAME custom_name  # Optional: override output filename
    DEBUG_ARGS "-t"  # Optional: debugging arguments
)
```

#### `ida_add_loader(name ...)`
Creates an IDA file loader.

```cmake
ida_add_loader(myloader
    SOURCES loader.cpp
)
```

#### `ida_add_procmod(name ...)`
Creates an IDA processor module.

```cmake
ida_add_procmod(myproc
    SOURCES ana.cpp emu.cpp out.cpp
)
```

#### `ida_add_idalib_exe(name ...)`
Creates an executable using IDA as a library.

```cmake
find_package(idasdk REQUIRED)

ida_add_idalib_exe(myapp
    SOURCES main.cpp
)
```

## Project Templates

Ready-to-use templates are available in `$IDASDK/ida-cmake/templates/`:

- `plugin/` - Basic plugin template
- `plugin-no-bootstrap/` - Plugin using CMAKE_PREFIX_PATH approach (no bootstrap include)
- `loader/` - File loader template
- `procmod/` - Processor module template
- `idalib/` - IDA as library template

Copy a template to start your project:

```bash
cp -r %IDASDK%/ida-cmake/templates/plugin/* my-plugin/
cd my-plugin
cmake -B build
cmake --build build
```

## AI/Claude Agent Support

ida-cmake includes built-in support for AI-assisted development with Claude. When starting a new project from a template or adding to an existing project:

```bash
# After configuring your project
cmake -B build

# Install the ida-cmake agent and CLAUDE.md to your project
cmake --build build --target install_idacmake_agent
```

This will:
- Install `.claude/agents/ida-cmake.md` - Specialized agent for IDA SDK builds
- Create `CLAUDE.md` - Project context file with your addon name
- Enable AI assistance for build configuration, troubleshooting, and SDK usage

The agent provides expertise in:
- CMake configuration for IDA addons
- Platform-specific build issues
- IDA SDK API usage and examples
- Debugging setup for VS Code and Visual Studio

## Examples

### Multiple Plugins in One Project

```cmake
cmake_minimum_required(VERSION 3.27)
project(MyPlugins)

include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

ida_add_plugin(plugin1 SOURCES plugin1.cpp)
ida_add_plugin(plugin2 SOURCES plugin2.cpp)
```

### Using External Libraries

```cmake
find_package(idasdk REQUIRED)
find_package(Boost REQUIRED COMPONENTS filesystem)

ida_add_plugin(advanced_plugin
    SOURCES main.cpp
    LIBRARIES
        Boost::filesystem
        ${Z3_LIBRARIES}
    INCLUDES
        ${Boost_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIRS}
)
```
