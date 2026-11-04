# Third-party notices

## AgX and AgX Punchy tone mapping

The shader in `GmProject/shaders/common_tonemap_agx` is adapted from Google
Filament's `ToneMapper.cpp` implementation and has been modified for GLSL,
Mine-imator's linear Rec. 709 input, and Shady shader-library integration.

Copyright 2021 The Android Open Source Project. Licensed under the Apache
License, Version 2.0.

Source: https://github.com/google/filament/blob/main/filament/src/ToneMapper.cpp

## PBR Neutral tone mapping

The shader in `GmProject/shaders/common_tonemap_pbr_neutral` is adapted from
the Khronos PBR Neutral reference implementation and has been modified for
Mine-imator's naming, formatting, and Shady shader-library integration.

Copyright 2023 The Khronos Group Inc. Licensed under the Apache License,
Version 2.0.

Source: https://github.com/KhronosGroup/ToneMapping/blob/main/PBR_Neutral/pbrNeutral.glsl

The full Apache License 2.0 text is available at
`LICENSES/Apache-2.0.txt`.
