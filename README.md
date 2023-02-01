# Introduction

`ida-cmake` provides a convenience CMake build script template for compiling IDA addons on Windows, Linux and macOS (Intel or Apple Silicon). It requires very minimal set up and little to zero knowledge of the IDA SDK build system and how to configure it (especially on MS Windows, which can be very tedious).

>*`ida-cmake` has been tested the IDA SDK 7.2 and onwards.*

# Installation

Clone this project into the IDA SDK folder. The final folders layout should look like this:

```
<idasdk>
<idasdk>\ida-cmake
<idasdk>\plugins
<idasdk>\lib
<idasdk>\bin
etc.
```

Alternatively, if you have multiple IDA SDKs installed, it does not make sense to clone `ida-cmake` repeatedly into each SDK folder. In that case, just use symbolic links.

For example, on Windows:

```batch
mklink /j c:\idasdk82\ida-cmake c:\projects\ida-cmake
mklink /j c:\idasdk80\ida-cmake c:\projects\ida-cmake
```

Once installed, simply export an environment variable called `IDASDK` and make it point to the IDA SDK folder.

## IDABIN

`IDABIN`, an optional environment variable, if specified, should point to IDA's installation location.

Since in most cases the IDA binaries are located in a non-writable path (`Program Files` for example), two cases are advised here:

1) `%APPDATA%\Hex-Rays\IDA Pro`:

```bash
set IDABIN=%APPDATA%\Hex-Rays\IDA Pro
```
(or `export IDABIN=...` on *nix platforms)

2) Or just don't specify the variable and let it compute to the default value `<IDASDK>/bin`.

# Compiling IDA addons

Plugins, file loaders, processor modules will be referred to as _addons_.

In the `CMakeLists.txt` build script, you can specify the type of addon being compiled by simply providing its name:

- `set(PLUGIN_NAME  my_simple_plugin)`: specifies that this is a [plugin](plugins/).
- `set(LOADER_NAME  my_loader)`: specifies that this is a [file loader module](loaders/).
- `set(PROCMOD_NAME my_procmod)`: specifies that this is a [processor module](module/).

In the following subsections, we describe how to configure `ida-cmake` for _plugins_, however one can substitute `PLUGIN_` with `LOADER_` or `PROCMOD_` to achieve the same for other addon types.

## Customizing your plugin information

To get started, simply copy the desired template plugin CMake build [script](plugins/sample/CMakeLists.txt) from the [plugins/](plugins/) samples to your plugin source directory and edit it accordingly:

```cmake
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(MyPluginProjectName)

include($ENV{IDASDK}/ida-cmake/common.cmake)

set(PLUGIN_NAME          mysample)
set(PLUGIN_SOURCES       mysample.cpp)
set(PLUGIN_OUTPUT_NAME   mysample-output)

generate()
```

Specify the solution name with `project()`. This is relevant when you have more than one plugin in the same directory.

Here are all the supported addon variables:

* `PLUGIN_NAME` is the project name. It is also used as the binary name if the `PLUGIN_OUTPUT_NAME` is absent
* `PLUGIN_SOURCES` is a space separated list of source files that make up the plugin
* `PLUGIN_OUTPUT_NAME` is an optional variable that lets you override the binary file name. This is useful if you want to have your plugin load before other plugins (IDA sorts and loads plugins in alphabetical order)
* `PLUGIN_LINK_LIBRARIES` additional link libraries used by the plugin.
* `PLUGIN_INCLUDE_DIRECTORIES` additional include directories used by the plugin.
* `PLUGIN_RUN_ARGS` specify the default command line arguments to pass when you run your plugins from the IDE (only works with Visual Studio). If not specified, then IDA will run with a temporary database (`-t` switch).
* `DISABLED_SOURCES` is used to specify a list of source files that should be listed in the project but should not be compiled (they are meant to be used with `#include` for example).

Finally, call the `generate` macro.

### Two or more plugins sharing the same source files

It is possible to have a single plugin folder describing two or more plugins (when plugins share the same source code for instance).
To do that, check the [ida-cmake/plugins/twoplugins](plugins/twoplugins) folder.

In essence, all you have to do is something like the following:

```cmake
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(TwoPlugins)

include($ENV{IDASDK}/ida-cmake/common.cmake)

# Plugin 1
set(PLUGIN_NAME              mysample1)
set(PLUGIN_SOURCES           mysample1.cpp)
generate()

# Plugin 2
set(PLUGIN_NAME              mysample2)
set(PLUGIN_SOURCES           mysample2.cpp)
generate()
```

## Generating project files

Now that all the prerequisit steps are configured, let's use CMake to generate our build scripts (using a [generator](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html) of our choice).

<u>Notes:</u>

* Add the `-DEA64=YES` switch to CMake if you want to build for `ida64`.
* Obsolete: add the argument `-DMAXSTR=<new_len>` to change the default value of `MAXSTR` from 1024.

<u>For `ida`</u>

In your plugin source directory, type the following shell commands:

```bash
mkdir build
cd build
cmake ..
```

<u>For `ida64.exe`</u>

Just pass the `-DEA64=YES` switch:

```
mkdir build64
cd build64
cmake .. -DEA64=YES
```

### On MS-Windows

* The default generator (CMake's `-G` switch) is Visual Studio.
* It might be required to pass the `-A x64` switch 

In the build folders, if the Visual Studio generator was used, then you will have a Visual Studio solution. Feel free to open the solution and build it from the IDE going forward.

## Generating project files for multiple addons

To configure CMake for multiple addons existing in their own folders, just create a `CMakeLists.txt` file that includes the directories of the addons in question:

```cmake
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(AllPlugins)

add_subdirectory(twoplugins)
add_subdirectory(sample)
```

Then create a build folder (as described in the previous steps):

```bash
mkdir build
cd build
cmake -A x64 ..
```

Now you have a project that contains all the aforementioned directories.

Please check the template CMake file located here: `ida-cmake/plugins/CMakeLists.txt`.

### Generating project files for Linux/macOS

Nothing special is required. Just create the proper build folder and invoke CMake:

```bash
mkdir build
cmake ..
```

## Specify the IDASDK and IDABIN per addon

Instead of specifying the `IDASDK` environment variable, it is also possible to pass it via the CMake command line switch: `-DIDASDK=/path/to/idasdk`. The same goes for `IDABIN`. Here's an example:

```bash
cd build
cmake .. -DIDASDK=</path/to/idasdk> -DIDABIN="%APPDATA%\Hex-Rays\IDA Pro" 
```

For this to work, your CMake build script should be able to include the needed bootstrap CMake script correctly (note the `include`):

```cmake
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(mysample)

# Plugin 1
set(CMAKE_CXX_STANDARD 17)

include(${IDASDK}/ida-cmake/common.cmake)

set(PLUGIN_NAME      mysample)
set(PLUGIN_SOURCES   mysample.cpp)
set(PLUGIN_RUN_ARGS  "-t -z10000") # Debug messages for the debugger

generate()
```

Please see [sample_anysdk](plugins/sample_anysdk) sample.

## Building

After the project has been generated, the next step is to build the addon:

```
cmake --build . --config Debug
```

or:

```
cmake --build . --config Release
```