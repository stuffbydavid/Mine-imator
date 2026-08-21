# CppGen

Converts the GameMaker scripts and objects of Mine-imator found in `GmProject` to C++ code into `CppProject/Generated/`. The missing GML functions, as defined in `gml.json`, are then mapped to C++ replacements found in `CppProject/Gml/`. Note that this software is not general-purpose and won't work outside the Mine-imator project.

Usage:
```
CppGen.exe [Repository root] [gml.json file]
```

Build and run:

```
cd CppGen
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
build/CppGen.exe
```
The repository root directory defaults to `../../`, while the `gml.json` file path defaults to `../gml.json`.