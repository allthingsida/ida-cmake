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

The `IDABIN` environment variable should point to where you have IDA executables folder.
Since in most cases the IDA binaries are located in a non-writable path (Program Files for example), two cases are advised here:

- `C:\Users\[username]\AppData\Roaming\Hex-Rays\IDA Pro`
- `[IDASDK]\bin`

If this envorinment variable is missing, then the compiled addons will be generated in `[IDASDK]\bin`.

# Plugins

## Customizing your plugin information

To build plugins, simply copy the template plugins CMake file from `ida-cmake/plugins/CMakeLists.txt` to your plugin source directory and edit it accordingly:

```
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

set(PLUGIN_NAME              mysample)
set(PLUGIN_SOURCES           mysample.cpp)
set(PLUGIN_OUTPUT_NAME       mysample-output)

include($ENV{IDASDK}/ida-cmake/plugins.cmake)

```

* `PLUGIN_NAME` is the project name. It is also used as the binary name if the `PLUGIN_OUTPUT_NAME` is absent
* `PLUGIN_SOURCES` is a space separated list of source files that make up the plugin
* `PLUGIN_OUTPUT_NAME` is an optional variable that lets you override the binary file name. This is useful if you want to have your plugin load before other plugins (IDA sorts and loads plugins in alphabetical order)


## Generating sources

In your plugin source directory, type the following shell commands:
```
mkdir build
cd build
cmake -A x64 .. -DEA64=NO
```
(note: change the arguments to `EA64=YES` if you want to build for `ida64`)

Now you will have Visual Studio solution in this folder. You can build using Visual Studio or from the command line like this:

```
cmake --build . --config Release
```

