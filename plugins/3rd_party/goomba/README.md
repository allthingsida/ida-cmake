To build [gooMBA](https://github.com/HexRaysSA/goomba) with [CMake](https://cmake.org), just copy the [CMakeLists.txt](CMakeLists.txt) build script to the `gooMBA` source code directory.

>Make sure you have Z3 libraries deployed correctly in a folder of your choice (or in `<goomba>/z3`).

Now, configure CMake accordingly. In the `<goomba>` folder, run:

```bash
mkdir build
cmake .. -DZ3_DIR=<z3_dir>
```

>Note: if `Z3_DIR` is not specified, it will default to `<goomba>/z3`.

Then build with:

```
cmake --build .
```

For ida64 builds, specify the additional `-DEA64=YES` switch in the configuration step:

```bash
mkdir build64
cd build64
cmake .. -DEA64=YES
```
