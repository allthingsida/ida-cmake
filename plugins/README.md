The `plugins` folder contains CMake build scripts that serve as template or a complete build script for some open source projects:

* `sample`: A generic build script for IDA plugins
* `sample_anysdk`: A generic build script that expects no `IDASDK` environment variable, instead a user passed `-DIDASDK=/path/to/sdk` from the command line
* `twoplugins`: A build script for a project of two or more plugins
* 3rd-party plugins:
    * `goomba`: Build script for the [goomba](https://github.com/HexRaysSA/goomba/) plugin
    * `pdb`: Build script for the `pdb` plugin in the IDA SDK

