# Dependencies

gooMBA requires IDA SDK (8.2 or later) and the [z3 library](https://github.com/Z3Prover/z3).

# Building gooMBA with ida-cmake

To build `gooMBA` with [ida-cmake](https://github.com/0xeb/ida-cmake).
Grab `ida-cmake` and clone it as per its instructions to the `<idasdk>` folder, then configure it properly.

Glone `gooMBA` source code to any folder of your choice.

Make sure you have Z3 libraries deployed correctly in a folder of your choice (or in `<goomba>/z3`).

Now, configure CMake accordingly. In the `<goomba>` folder, run:

```bash
mkdir build
cmake .. -DZ3_DIR=<z3_dir>
```

On MS Windows, configure `cmake` with `-A x64`:

```bash
cmake .. -A x64 -DZ3_DIR=<z3_dir>
```

Note: if `Z3_DIR` is not specified, it will default to `<goomba>/z3`.

Then build with:

```
cmake --build .
```

For ida64 builds, specify the additional `-DEA64=YES` switch in the configuration step:

```bash
mkdir build64
cd build64
cmake .. -DEA64=YES -DZ3_DIR=<z3_dir>
```
