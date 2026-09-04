# CppGen
A tool used by the build system that converts the GameMaker scripts and objects of Mine-imator found in `GmProject` to C++ code into `CppProject/Generated/`. The used GML functions, as defined in `gml.json`, are then mapped to C++ replacements found in `CppProject/Gml/`. This program runs automatically when compiling and detects changes in `.gml` files during development, it needs no manual invocation.

Note that this software is not general-purpose and won't work outside the Mine-imator project.

## GML specification
If you use new GameMaker features, you must update `gml.json`:
* New constants are added to `"constants"`.
* New built-in variables are added to `"variables"` and are implemented in `CppProject/`.
* New built-in functions are added to `"functions"` and are implemented in `CppProject/Gml/`.
* New keywords or using unsupported GameMaker features may require bigger CppGen/CppProject changes.

## Usage (optional)
```
CppGen.exe [repo-root] [gml-spec] [--clean]
```

The repository root directory defaults to `../../`, while the GML specification file defaults to `../gml.json`. With the `--clean` flag supplied, the existing cache from previous runs will be ignored.

## Building CppGen (Windows) (optional):
```
cd CppGen
cmake -S . -B build -A x64
cmake --build build --parallel --config Release
build/CppGen.exe .. gml.json
```
## Building CppGen  (Mac/Linux) (optional):
```
cd CppGen
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
build/CppGen .. gml.json
```