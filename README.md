# ida-cmake - CMake Build System for the IDA SDK

CMake build system for developing IDA Pro addons (plugins, loaders, processor modules and standalone idalib apps) using the IDA SDK.

>For IDA 9.1 and below, please check the [9.1](https://github.com/allthingsida/ida-cmake/tree/9.1) branch.

## Two Ways to Use ida-cmake

ida-cmake provides **two approaches** for building IDA addons:

1. **Convenience Functions** (Recommended) - Simple one-liners like `ida_add_plugin()`
2. **Standard CMake** - Traditional `add_library()`/`add_executable()` with the provided interface targets

Both approaches are fully supported. Choose based on your preference!

> This dual approach follows the same pattern used by major projects like Qt (`qt_add_executable()`), LLVM (`add_llvm_library()`), and CUDA (`cuda_add_library()`) - providing convenience functions while maintaining full standard CMake compatibility.

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

#### Option A: Using Convenience Functions (Recommended)

Create a `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.27)
project(myplugin)
set(CMAKE_CXX_STANDARD 17)

# Include IDA SDK bootstrap
include($ENV{IDASDK}/ida-cmake/bootstrap.cmake)
find_package(idasdk REQUIRED)

# Add plugin with one simple function
ida_add_plugin(myplugin
    SOURCES main.cpp
)
```

#### Option B: Using Standard CMake

If you prefer vanilla CMake, use our interface targets directly. See [`templates/plugin-vanilla/`](templates/plugin-vanilla/) for a complete example:

```cmake
# Standard CMake approach
add_library(myplugin SHARED main.cpp)
target_link_libraries(myplugin PRIVATE idasdk::plugin)

# Plus platform-specific settings (see template for details)
```

Build (same for both approaches):

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

#### `ida_add_idalib(name ...)`
Creates a target using IDA as a library. Can build executables, shared libraries, or static libraries. For vanilla CMake approach, see [`templates/idalib-vanilla/`](templates/idalib-vanilla/).

```cmake
# Executable (default)
ida_add_idalib(myapp
    SOURCES main.cpp
    TYPE EXECUTABLE  # Optional, default
)

# Shared library
ida_add_idalib(mylib
    SOURCES lib.cpp
    TYPE SHARED
)

# Static library
ida_add_idalib(mystatic
    SOURCES static.cpp
    TYPE STATIC
)
```

## IDA 9.x Plugin Metadata

IDA Pro 9.0+ supports organizing plugins in subfolders with `ida-plugin.json` metadata files. This feature is **optional** and **opt-in**.

### Using Metadata (Optional)

To deploy a plugin with metadata:

**1. Create an `ida-plugin.json` file** in your project:

```json
{
  "IDAMetadataDescriptorVersion": 1,
  "plugin": {
    "name": "My Plugin",
    "entryPoint": "myplugin",
    "categories": ["collaboration-and-productivity"],
    "logoPath": "logo.png",
    "idaVersions": ">=9.0",
    "description": "Brief description of your plugin's functionality",
    "version": "1.0.0"
  }
}
```

**Required fields:** `IDAMetadataDescriptorVersion`, `name`, `entryPoint`, `categories`, `description`, `version`  
**Optional fields:** `logoPath`, `idaVersions`

**Available categories:**
- `disassembly-and-processor-modules`
- `file-parsers-and-loaders`
- `decompilation`
- `debugging-and-tracing`
- `deobfuscation`
- `collaboration-and-productivity`
- `integration-with-third-parties-interoperability`
- `api-scripting-and-automation`
- `ui-ux-and-visualization`
- `malware-analysis`
- `vulnerability-research-and-exploit-development`
- `other`

**2. Specify the metadata file** in your CMakeLists.txt:

```cmake
ida_add_plugin(myplugin
    SOURCES main.cpp
    METADATA_JSON ida-plugin.json
)
```

**3. Build normally.** Your plugin will deploy to `$IDABIN/plugins/myplugin/` with metadata.

> **Note:** If the specified JSON file doesn't exist, ida-cmake will automatically generate a template for you to customize.

### Deployment Structure

**Without metadata (traditional - default):**
```
$IDABIN/plugins/myplugin.dll
```

**With metadata (IDA 9.x - opt-in):**
```
$IDABIN/plugins/myplugin/
├── myplugin.dll
└── ida-plugin.json
```

### Multi-Plugin Projects with Metadata

Each plugin gets its own subfolder to avoid conflicts:

```cmake
ida_add_plugin(plugin1
    SOURCES plugin1.cpp
    METADATA_JSON plugin1-metadata.json
)

ida_add_plugin(plugin2
    SOURCES plugin2.cpp
    METADATA_JSON plugin2-metadata.json
)
```

Deploys to:
```
$IDABIN/plugins/
├── plugin1/
│   ├── plugin1.dll
│   └── ida-plugin.json
└── plugin2/
    ├── plugin2.dll
    └── ida-plugin.json
```

See [Hex-Rays documentation](https://docs.hex-rays.com/user-guide/plugins/plugin-submission-guide) for the complete metadata format specification.


## Interface Targets (For Standard CMake Users)

If you prefer standard CMake commands, ida-cmake provides interface targets:

- **`idasdk::plugin`** - For IDA plugins
- **`idasdk::loader`** - For file loaders
- **`idasdk::procmod`** - For processor modules
- **`idasdk::idalib`** - For standalone idalib applications

These targets automatically handle all SDK configuration (includes, defines, libraries, platform settings) through CMake's transitive properties. See [`templates/plugin-vanilla/`](templates/plugin-vanilla/) for a complete working example.

## Configuration Options

ida-cmake provides several CMake options to customize the build:

### `IDACMAKE_ENABLE_DEBUGGER`

Enable debugger module support targets (disabled by default).

```bash
cmake -B build -DIDACMAKE_ENABLE_DEBUGGER=ON
```

When enabled, provides these additional targets for building custom debugger plugins:
- **`idasdk::dbg`** - Base debugger module support
- **`idasdk::dbg::pc`** - PC architecture debugger support
- **`idasdk::dbg::arm`** - ARM architecture debugger support

Most users don't need these targets unless developing custom debugger plugins.

## Project Templates

Ready-to-use templates are available in `$IDASDK/ida-cmake/templates/`:

- `plugin/` - Basic plugin template (convenience functions)
- `plugin-vanilla/` - Plugin using standard CMake commands
- `plugin-no-bootstrap/` - Plugin using CMAKE_PREFIX_PATH approach (no bootstrap include)
- `loader/` - File loader template
- `procmod/` - Processor module template
- `idalib/` - IDA as library template (convenience functions)
- `idalib-vanilla/` - IDALib using standard CMake commands

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

## Platform-Specific Notes

### macOS Universal Binaries

macOS universal binaries (combining arm64 and x86_64) are **fully supported** via automatic library merging with `lipo`.

**How it works:** When you set `CMAKE_OSX_ARCHITECTURES` to multiple architectures, ida-cmake automatically:
1. Detects architecture-specific IDA SDK libraries
2. Merges them into universal libraries using `lipo` at configure time
3. Links your addon against the merged universal libraries

**Usage:**

```bash
# Build universal binary (single command!)
cmake -B build -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
cmake --build build --config Release

# Verify the output is universal
lipo -info build/myplugin.dylib
# Should show: Architectures in the fat file: myplugin.dylib are: x86_64 arm64
```

**Single-architecture builds:** Either omit `CMAKE_OSX_ARCHITECTURES` (auto-detects host) or specify one architecture:
```bash
cmake -B build -DCMAKE_OSX_ARCHITECTURES=arm64  # or x86_64
```

**Technical details:** The IDA SDK provides architecture-specific libraries (`lib/arm64_mac_clang_64/libida.dylib` and `lib/x64_mac_clang_64/libida.dylib`). ida-cmake uses `lipo` to merge these into universal libraries stored in `build/ida-universal-libs/`, which are then linked to your addon.

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

For the standard CMake approach, see [`templates/plugin-vanilla/`](templates/plugin-vanilla/).

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
