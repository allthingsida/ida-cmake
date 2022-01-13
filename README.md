# Introduction

This is a convenience CMake template for compiling IDA addons. This has been tested on MS-Windows but should work in Linux and macOS in theory.
The CMake templates only supports building plugins for the IDA SDK 7.2 and onwards.

# Installation

Clone this project into IDA SDK folder as such:

```
<idasdk>
<idasdk>\plugins
<idasdk>\lib
<idasdk>\bin
<idasdk>ida-cmake
etc.
```

# Compiling IDA addons

The first step in this process is to define the following environment variables:

## IDASDK

This variable should point to where you unpacked IDA's SDK

## IDABIN

The, optional, `IDABIN` environment variable should point to where you have IDA executables folder.
Since in most cases the IDA binaries are located in a non-writable path (Program Files for example), two cases are advised here:

- `C:\Users\[username]\AppData\Roaming\Hex-Rays\IDA Pro`
- `[IDASDK]\bin`

If this envorinment variable is missing, then the compiled addons will be generated in `[IDASDK]\bin`.

# Plugins / Loaders

Both plugins are loaders will be referred to as addons. In the `CMakeLists.txt` file, one can specify what kind of addon by simply specifying the name:

- `set(PLUGIN_NAME  my_simple_plugin)`: specifies that this is a plugin
- `set(LOADER_NAME  my_loader)`: specifies that this is a file loader module

In the following subsections, we describe how to configure `ida-cmake` for plugin addons, however one can substitute `PLUGIN_` with `LOADER_` to achieve the same for file loaders.

## Customizing your plugin information

To build plugins, simply copy the template plugins CMake file from `ida-cmake/plugins/sample/CMakeLists.txt` to your plugin source directory and edit it accordingly:

```
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(MyPluginProjectName)

set(PLUGIN_NAME              mysample)
set(PLUGIN_SOURCES           mysample.cpp)
set(PLUGIN_OUTPUT_NAME       mysample-output)

include($ENV{IDASDK}/ida-cmake/plugins.cmake)
```

* Specify the solution name with `project()`. This is relevant when you have more than one plugin in the same directory
* `PLUGIN_NAME` is the project name. It is also used as the binary name if the `PLUGIN_OUTPUT_NAME` is absent
* `PLUGIN_SOURCES` is a space separated list of source files that make up the plugin
* `PLUGIN_OUTPUT_NAME` is an optional variable that lets you override the binary file name. This is useful if you want to have your plugin load before other plugins (IDA sorts and loads plugins in alphabetical order)
* `PLUGIN_RUN_ARGS` specify the default command line arguments to pass when you run your plugins from the IDE (only works with Visual Studio). If not specified, then IDA will run with a temporary database (`-t` switch).

### Two or more plugins sharing the same source files

It is possible to have a single plugin folder describing two or more plugins (when plugins share the same source code for instance).
To do that, check the `ida-cmake/plugins/twoplugins` folder. In essence, all you have to do is something like the following:

```
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(TwoPlugins)

# Plugin 1
set(PLUGIN_NAME              mysample1)
set(PLUGIN_SOURCES           mysample1.cpp)
include($ENV{IDASDK}/ida-cmake/plugins.cmake)

# Plugin 2
set(PLUGIN_NAME              mysample2)
set(PLUGIN_SOURCES           mysample2.cpp)
include($ENV{IDASDK}/ida-cmake/plugins.cmake)
```

## Generating project files

* Change the arguments below to `EA64=YES` if you want to build for `ida64`.
* Add the argument `-DMAXSTR=<new_len>` to change the default value of `MAXSTR` from 1024.

## Building on MS-Windows

### Building for `ida.exe`

In your plugin source directory, type the following shell commands:
```
mkdir build
cd build
cmake -A x64 .. -DEA64=NO
```
(note: On MS-Windows, the default generator (CMake's `-G` switch) is Visual Studio, therefore it is omitted from the command line arguments above)

Now you will have Visual Studio solution in this folder. You can build using Visual Studio or from the command line like this:

```
cmake --build . --config Release
```

### Building for `ida64.exe`

These steps differ a little from the above:
```
mkdir build64
cd build64
cmake -A x64 .. -DEA64=YES
```

## Building multiple plugins

To configure and build multiple plugins existing in their own folders, just create a `CMakeLists.txt` file that includes the directories of other plugins:

```
#
# CMake template for compiling more than one plugin
#
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project(AllPlugins)

add_subdirectory(twoplugins)
add_subdirectory(sample)
```

Then create a build folder (as described in the previous steps):
```
mkdir build
cd build
cmake -A x64 .. -DEA64=NO
```

Now you have a project that contains all the aforementioned directories.

Please check the template CMake file located here: `ida-cmake/plugins/CMakeLists.txt`.