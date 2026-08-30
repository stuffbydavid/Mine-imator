## Project map
* build-vs/ → Build folder (Windows)
* build-xcode/ → Build folder (Mac OS)
* build/ → Build folder (Unix)
* rendering/ → Rendering files (2.1-rendering branch only)
* CppGen/ → GML to C++ converter
* CppProject/ → Final executable project and DirectX/OpenGL graphics engine
* CppProject/Generated/ → CppGen output folder
* CppProject/External/ → Pre-built external libraries
* GmProject/ → GameMaker project for non-engine development
* BUILD.md → Build instructions
* Setup.ps1 → Build script (Windows PowerShell)
* Setup.sh → Build script (Unix Bash)

## Building
If asked to setup the build environment, follow the appropriate "Building Mine-imator" guide in BUILD.md depending on the OS/architecture and not "Building libraries", since pre-built libraries are supplied (except for Mac OS ARM). Some steps in the instructions require manual steps by the developer, make sure to point these out before continuing.

## Development
The project has a GameMaker/GML "frontend" which is converted to C++ code using the CppGen application, launched using `.\Setup.ps1 CppGen` (Windows) or `./Setup.sh CppGen` (Unix). Add missing GML features to CppGen/gml.json, then inform the developer about new additions:
* If a new constant is used, add it to `"constants"`.
* If a new built-in variable is used, add it to `"variables"`.
* If a new built-in function is used, add it to `"functions"` and implement it in CppProject/Gml/.
* New keywords or using unsupported GameMaker features will require CppGen changes, inform the developer about this and urge them to use alternatives.


General development practices:
* CppProject is used for the final product, not GameMaker, and should be preferred for validation.
* Do not build or run the project during development unless asked.
* Do not run CppGen after GML changes unless asked.
* Aim to follow the existing formatting/comment style in the GML/C++ codebases.

## Benchmarking/validation

If asked for validation of changes, pass in the `--benchmark_project <.miproject>` flag into Mine-imator to start running a project, which should be assumed to be `<build_folder>/dev_project/dev_project.miproject`, where every frame in the timeline is treated as a separate "test". If asked to validate rendering effects, use `<repo_dir>/rendering/benchmark_project/benchmark_project.miproject`. The rendering output and timing data should be validated against the files in baselines/ under the project folder for correctness, if available. Always check that the expected images are available/non-black/non-zero bytes and no runtime errors are printed/logged.

If tests succeed in the default DirectX mode, run Mine-imator again with `--gfx OpenGL` added to test OpenGL (Windows only) unless asked otherwise. If asked for a specific range of tests, use `--benchmark_start X` and `--benchmark_end Y`, or `--benchmark_full` to run through all frames in the project. For troubleshooting a rendering issue in the pipeline, pass in `--benchmark_exportpasses`, which should only be used sparingly for a specific test using the start/end parameters.
