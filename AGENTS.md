## Project map
* build-vs/ → Build folder (Windows)
* build-xcode/ → Build folder (Mac OS)
* build/ → Build folder (Unix)
* rendering/ → Rendering files (2.1-rendering branch only)
* CppGen/ → GML to C++ converter
* CppProject/ → Final executable project and DirectX/OpenGL graphics engine (this is the CMake `-S` input)
* CppProject/Generated/ → CppGen output folder
* CppProject/External/ → Pre-built external libraries
* GmProject/ → GameMaker project for non-engine development
* BUILD.md → Build instructions
* RENDER.md → Rendering settings for validation
* Setup.ps1 → Build setup script (Windows PowerShell)
* Setup.sh → Build setup script (Unix Bash)

## Build setup
If asked to setup the build environment, follow the appropriate "Building Mine-imator" guide in BUILD.md depending on the OS/architecture and not "Building libraries", since pre-built libraries are supplied (except for Mac OS ARM). Some steps in the instructions require manual steps by the developer, make sure to point these out before continuing. A permanent `DEV_DIR` variable should be set up rather than a temporary one.

## Build
Common build commands:
- Windows / Visual Studio:
  `cmake --build build-vs --config Debug --target Mine-imator --parallel`
- macOS / Xcode:
  `cmake --build build-xcode --config Debug --target Mine-imator --parallel`
- Linux / single-config generator:
  configure with `-DCMAKE_BUILD_TYPE=Debug`, then run
  `cmake --build build --target Mine-imator --parallel`

Use `Debug` for debugging unless optimized behavior or benchmark-representative performance is required, then use `RelWithDebInfo`. Don't use the developer-facing `DebugBenchmarks` or `RunBenchmarks` configs.

## Development
The project has a GameMaker/GML "front-end" which is converted to C++ code using the CppGen application, launched using `.\Setup.ps1 CppGen` (Windows) or `./Setup.sh CppGen` (Unix). Add missing GML features to CppGen/gml.json, then inform the developer about new additions:
* If a new constant is used, add it to `"constants"`.
* If a new built-in variable is used, add it to `"variables"` and implement its functionality it in CppProject/.
* If a new built-in function is used, add it to `"functions"` and implement it in CppProject/Gml/.
* New keywords or using unsupported GameMaker features will require CppGen changes, inform the developer about this and urge them to use alternatives.

If you make a change under CppProject/Generated/ and decide to keep it, you must back-port it into the correct .gml file. This directory is not versioned and will be overwritten by the next call to CppGen.

General development practices:
* Do not build or run the project during development unless asked.
* CppProject is used for the final product, not GameMaker, and should be preferred for validation.
* When running, use the build folder as the working directory, not the repository root.
* Do not run CppGen after GML changes unless asked.
* Aim to follow the existing formatting/comment style in the GML/C++ codebases:
    * Single line comments do not end with `.`
    * Local variables in GML code do not use `_`

## Validation/benchmarking
If asked for validation of changes, pass in the `--test <.miproject>` flag into Mine-imator to start running a project in headless mode, which should be assumed to be `<build_folder>/dev_project/dev_project.miproject`, where every frame in the timeline is treated as a separate "test". If asked to validate rendering effects, use `<repo_dir>/rendering/test_project/test_project.miproject`. The rendering output and timing data is saved in a timestamped folder under the runs/ subdirectory and should be validated against the files in baselines/ for correctness, if available. Always check that the expected images are available/non-black/non-zero bytes and no runtime errors are printed/logged. Report deviations in image output or unexpected performance drops.

On Windows, if tests succeed in the default DirectX mode, run Mine-imator again with `--gfx OpenGL` added to test OpenGL unless asked otherwise.

If asked for a specific range of tests, use `--start X` and `--end Y` (Y exclusive), or `--all` to run through all frames in the project. By default, the `flat`, `shaded` and `high` render modes will be tested, use `--mode <mode>` to limit the test to a specific mode. For typical, non-troubleshooting validation, all modes should be tested.

For debugging a rendering issue in the pipeline, use `--pass <pass>` to save a high-quality pass in a new folder with the current frame/test name. Possible values are `diffuse`, `specular`, `ao`, `shadows`, `indirect`, `indirectshadows`, `reflections`, `depth`, `normal`, `material` and `all` to save every pass.

To test render settings, use `--set "<settings>"` and pass in a comma-separated list of values, such as `"shadows=true,samples=64"`. You are advised to combine settings using spaces to perform multiple tests if needed, rather than multiple runs, for example `"shadows=true,samples=8 samples=16 samples=32"`. Consult RENDER.md for the full list of render and camera settings. For each frame, the settings are restored to their defaults found in `test_base.mirender`, if available.

Agents must include `--agent <agent-name>` in benchmark invocations, such as `--agent Codex` or `--agent Gemini`, so the run directory identifies its producer.
