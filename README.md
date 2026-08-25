# Mine-imator

<p align="center">
  <img src="https://www.mineimatorforums.com/uploads/monthly_2021_08/image.png.4699187f1f02be8222a5bf5100c1738f.png" width=800/>
  <br/>
  <br/>
  <img src="https://www.mineimatorforums.com/uploads/monthly_2023_03/336815532_programview.png.9212aa1f6d1bed63411408aa5e905ce0.png" width=800/>
</p>

Mine-imator is a 3D movie maker based on the sandbox game Minecraft, with over 10 million downloads since its launch in 2012. Version 2.0, the 10th anniversary update brings numerous additions including a new UI, new renderer, animation features, multiplatform support and 3D world importer.

Website and download: https://www.mineimator.com

The software is written using GameMaker Language and converted to a separate C++ environment using a custom built GML parser (CppGen). The final executable is built for Windows, Mac OS and Linux using the Qt framework, DirectX/OpenGL rendering and various other libraries.

## GameMaker project
You can open `GmProject/Mine-imator.yyp` directly in GameMaker-LTS2026 for development and debugging, but with the following restrictions:
* Windows-only due to `.dll` dependencies for file operations, window handling, audio importing and movie exporting
* Texture issues due to limitations with `sprite_add` and grayscale/tRNS chunks in transparent PNGs, affecting clouds and certain blocks/items found in Minecraft resource packs
* Slower overall performance
* No Minecraft world importer
* No cached scenery loading
* No drag-n-drop support for files into Mine-imator
* No multi-window support for secondary views
* No "Cancel" option when closing the application

To support all features you must prepare and compile the C++ project. For full build instructions, see `BUILD.md`.