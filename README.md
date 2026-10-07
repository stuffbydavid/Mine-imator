# MI-Shader-Fusion

MI-Shader-Fusion is a fork of [Mine-imator](https://github.com/stuffbydavid/Mine-imator), the 3D movie maker based on Minecraft, that renders scenes through real Minecraft shaderpacks. The goal is simple: what you see in the game with a shaderpack is what you get in Mine-imator, in the viewport and in exported images and movies.

<p align="center">
  <img src="https://www.mineimatorforums.com/uploads/monthly_2023_03/336815532_programview.png.9212aa1f6d1bed63411408aa5e905ce0.png" width=800/>
</p>

## Features

### Native shaderpacks
- Loads OptiFine/Iris shaderpacks (folders or `.zip` files) from the `Shaderpacks` folder in the Mine-imator user folder
- Pick a pack under **Render settings > Shaderpack**, set its options, and choose how many frames are rendered for packs with temporal effects
- Runs the full pack pipeline: shadow pass, sky, opaque and translucent geometry, deferred, composite and final passes, compute programs, custom textures and uniforms
- Scenery provides what packs expect from the game: Minecraft block IDs from the pack's `block.properties`, block and sky light with smooth lighting and ambient occlusion, mid-block and mid-texture data
- The camera, sun, time of day, weather and moon phase come from the Mine-imator environment
- Tested with Complementary Reimagined, Bliss, Super Duper Vanilla, Photon and Base-330

### Minecraft 26.3
- Blocks, models and textures of Minecraft 26.3, including pale oak and poplar wood, shelves, copper bulbs, grates, bars, chains, lanterns and chests, tuff, resin, cinnabar and sulfur blocks, crafters, vaults, trial spawners and the new plants
- Worlds, schematics and structure files (`.nbt`) from current versions import correctly

### Functional blocks as functional models
- When importing scenery from a world, doors, trapdoors, fence gates, buttons, pressure plates, chests, signs, beds, banners, heads, pots, bells and pistons become separate models that can be animated
- Sign text, banner patterns, head skins and pot sherds are imported from the world
- Toggle it under **Import from world > Settings > Import functional blocks as functional models**

## Requirements
- Shaderpacks need the OpenGL renderer, which is used on all platforms. Windows builds can be configured with `-DMI_GRAPHICS_API=D3D11` to use the original DirectX 11 renderer instead, without shaderpacks.
- Packs using compute shaders need OpenGL 4.3 (not available on Mac OS).

## Download
Windows builds are made by GitHub Actions on every push. Download `MI-Shader-Fusion-Windows-x64` from the latest successful run under [Actions](https://github.com/AssilF/MI-Shader-Fusion/actions/workflows/windows.yml), or the zip from [Releases](https://github.com/AssilF/MI-Shader-Fusion/releases) for builds of `master`. Unzip it and run `Mine-imator.exe`.
- Mob models are those of Minecraft 1.20.2; newer mobs are not included yet.

## Building
The software is written in GameMaker Language and converted to C++ with a custom GML parser (CppGen). The executable is built with Qt, DirectX/OpenGL rendering and other libraries. See [`BUILD.md`](BUILD.md) for full build instructions.

`Tools/ShaderPackTest` is a standalone test program for the shaderpack engine, and `Tools/MinecraftAssets` contains the scripts that generate the Minecraft data.

## Credits
Mine-imator is made by David Andrei and contributors: https://www.mineimator.com. Shaderpack formats are those of [OptiFine](https://optifine.net) and [Iris](https://github.com/IrisShaders/Iris). Minecraft is a trademark of Mojang Studios; this project is not affiliated with Mojang or Microsoft.
