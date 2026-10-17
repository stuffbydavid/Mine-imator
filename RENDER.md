**Note:** This document is meant as a reference for agents debugging rendering features.

# Render test settings

## Occlusion culling

The native renderer uses current-pass GPU depth queries on DirectX 11 and OpenGL
to conditionally draw scene meshes and instance batches. It tests an expanded
screen-space bounding rectangle at the nearest depth of the world-space bounds,
without writing color or depth. Queries never reuse visibility from an older
camera position or animation frame. OpenGL draws normally if a query result is
not ready; DirectX uses GPU predication without CPU readback.

Culling is opt-in with `--occlusionCulling` for camera color, G-buffer and auxiliary passes.
It applies across scene object types, but bypasses draws below 1,024 indices,
wind-deformed batches, bounds crossing the near plane, and passes without normal
depth testing. GPU model bends retain their conservative deformation bounds.
Shadow, selection, picking, preview and multi-view passes are unchanged.
Transparent geometry can be culled behind existing depth, but the proxy itself
never becomes an occluder. No opaque depth prepass or draw reordering is added.
The query pool is capped at 4,096 queries per application frame; further draws
render normally until the pool is reset on the next frame.

Use `--noOcclusionCulling` to disable queries for image and performance
comparisons. Test all three renderers on DirectX and OpenGL, including animated
occluders, camera cuts, near-plane intersections, transparency, wind, bends,
AA jitter, instanced objects and off-screen shadow casters. Compare saved images
with culling disabled. GPU-conditional draws still count as submitted draws in
the existing CPU statistics; profile GPU timings to measure savings. Query
overhead can outweigh savings in scenes with little hidden geometry. Initial
Debug comparisons of the rendering fixture showed approximately 5-8% additional
render time, so culling remains disabled by default pending optimized profiling.

## GPU model bending

The native renderer reuses segmented vertex buffers for smooth timeline block
bends and updates per-object shader parameters instead of regenerating vertices
when bend angles change. Position deformation is shared by color, depth, shadow, and
selection shaders; lighting normals follow the same bend. Bounds conservatively
enclose rotations around the bend pivot, so deformed meshes remain visible.

Blocky single-axis bends, shapes with corner offsets, planes (including extruded
planes), normal-mapped shapes, and shapes with height-limited vertex wind retain
CPU deformation. Resource previews and particle templates retain CPU meshes.
Changing normal-map availability or switching bend style rebuilds timeline meshes
because deformation eligibility or segment topology can change. GameMaker
continues to use CPU deformation.

Common midpoint and endpoint rotations are cached as compact quaternions; other
segment weights use shader-side easing and rotation. Unbent shapes keep their
default buffers until bending starts, and existing GPU buffers survive crossings
through zero.

This moves work out of CPU animation updates, but adds GPU vertex work and
per-object parameters. It does not guarantee faster exports, particularly with
the realistic renderer's repeated passes. Profile an optimized build before
drawing production-performance conclusions.

For validation, animate bends through zero and positive/negative angles on all
six bend sides, including rotated and mirrored shapes. Check smooth and blocky
styles, normal maps, corner offsets, wind, shadows, selection, and frustum edges
with all three renderers on DirectX and OpenGL. Compare against a CPU baseline;
animated smooth blocks should retain their vertex-buffer IDs across angle
updates rather than allocate/upload new geometry.

## Test runner

Use `--set "<settings>"` with Mine-imator's test runner (`--test "<.miproject>"`) in non-Release builds to override project render or camera settings. Separate settings in one test with commas:

```text
--set "shadows=true,samples=64,fov=70"
```

Separate groups with spaces to create multiple tests from one run, with new settings appending previous ones:

```text
--set "shadows=true,samples=8 samples=16 samples=32"
```

Percentages shown in the interface are documented below as their internal decimal values, so use `0.5` for an interface value of 50%. Colors are GameMaker color integers in the range `0x000000`-`0xFFFFFF` (`0xBBGGRR`), supplied as decimal numeric values because the expression parser does not accept hexadecimal or named color constants.

The ranges below are the ranges supported by the corresponding interface controls and rendering code. The test helper assigns values directly without clamping them, so it may accept an out-of-range number syntactically even when the result is unsupported. `no limit` corresponds to the application's practical numeric limit of 100,000,000.

## Project render settings

| Setting | Values | Description |
| --- | --- | --- |
| `samples` | Integer, 1-256 | Number of render samples |
| `dof_quality` | Integer, 8-64 | Depth of field taps per pixel (default 16 in both renderers) |
| `dof_realistic_blur` | Boolean | Standard only: use per-pixel blur sampling (off by default) |
| `distance` | 1,000-100,000 | Far render distance |
| `ssao` | Boolean | Enable screen-space ambient occlusion |
| `ssao_radius` | 0-256 | SSAO sampling radius |
| `ssao_power` | 0-no limit | SSAO strength |
| `ssao_color` | Color integer | SSAO tint color |
| `ssao_always_visible` | Boolean | Apply SSAO to all diffuse lighting instead of ambient lighting only |
| `shadows` | Boolean | Enable shadows |
| `shadows_blur_quality` | Integer, 0-64 | Standard renderer shadow-blur quality |
| `shadows_blur_size` | 0-4 | Shared shadow blur radius |
| `shadows_sun_cascades` | Integer, 1-5 | Number of separate sun shadow maps used to improve shadow detail over close and large distances. |
| `shadows_sun_buffer_size` | 256, 512, 1024, 2048, 4096, or 8192 | Sun shadow-map resolution; 8192 is offered only when supported by the GPU |
| `shadows_spot_buffer_size` | 256, 512, 1024, 2048, 4096, or 8192 | Spot-light shadow-map resolution; 8192 is offered only when supported by the GPU |
| `shadows_point_buffer_size` | 256, 512, 1024, 2048, 4096, or 8192 | Point-light shadow-map resolution; 8192 is offered only when supported by the GPU |
| `shadows_transparent` | Boolean | Let transparent textures affect shadow maps |
| `subsurface_samples` | Integer, 0-32 | Subsurface-scattering quality/sample count |
| `subsurface_backlight_spread` | 0-1 | Subsurface backlight spread |
| `subsurface_backlight_strength` | 0-no limit | Subsurface backlight strength |
| `subsurface_bright_backlight` | true/false | Allow brighter, less realistic subsurface backlighting |
| `indirect` | Boolean | Enable indirect lighting |
| `indirect_precision` | 0-1 | Indirect-lighting buffer precision/scale |
| `indirect_resolution` | 1, 0.5, 0.25, or 0.125 | Indirect-lighting raytrace resolution (`Full`, `Half`, `Quarter`, or `Eighth`) |
| `indirect_bounces` | Integer, 1-8 | Number of indirect-lighting bounces |
| `indirect_blur_radius` | 0-5 | Indirect-lighting blur radius |
| `indirect_strength` | 0-no limit | Indirect-lighting strength |
| `reflections` | Boolean | Enable screen-space reflections |
| `reflections_precision` | 0-1 | Reflection buffer precision/scale |
| `reflections_resolution` | 1, 0.5, 0.25, or 0.125 | Reflection raytrace resolution (`Full`, `Half`, `Quarter`, or `Eighth`) |
| `reflections_bounces` | Integer, 1-8 | Number of reflection bounces |
| `reflections_thickness` | 0.1-no limit | Reflection ray thickness |
| `reflections_fade_amount` | 0-1 | Reflection edge/distance fade amount |
| `glow` | Boolean | Enable material glow |
| `glow_radius` | 0-no limit | Glow blur radius |
| `glow_intensity` | 0-no limit | Glow intensity |
| `aa` | Boolean | Enable anti-aliasing |
| `aa_mode` | 0-1 | Anti-aliasing method (`0` = progressive AA, `1` = FXAA) |
| `aa_power` | 0-3 | Anti-aliasing strength |
| `bend_style` | `"blocky"` or `"realistic"` | Block/character bend deformation style |
| `opaque_leaves` | Boolean | Render leaves as opaque geometry |
| `liquid_animation` | Boolean | Enable animated liquid waves |
| `water_reflections` | Boolean | Enable the default reflective water material |
| `water_roughness` | 0-1 | Default water material roughness |
| `water_wave_strength` | 0-1 | Default water material wave strength |
| `water_wave_speed` | 0-no limit | Default water material wave speed |
| `water_wave_detail` | Integer, 1-8 | Default water material wave detail |
| `block_emissive` | 0-no limit | Default block/material emissive strength |
| `block_subsurface` | 0-no limit | Default block/material subsurface radius |
| `glint_speed` | 0-no limit | Enchantment glint animation speed |
| `glint_strength` | 0-no limit | Enchantment glint strength |
| `texture_filtering` | Boolean | Enable mipmapped texture filtering |
| `transparent_block_texture_filtering` | Boolean | Apply texture filtering to transparent blocks |
| `texture_filtering_level` | Integer, 0-5 | Mipmap/texture-filtering level |
| `alpha_hashing` | Boolean | Allow hashed transparency in Realistic renders |
| `alpha_mode` | `0` = blend, `1` = hashed | Project transparency mode in Realistic renders |
| `tonemapper` | `0` = none, `1` = Reinhard, `2` = ACES, `3` = Uchimura, `4` = Lottes, `5` = Hable, `6` = GT7 Curve, `7` = PBR Neutral, `8` = AgX, `9` = AgX Punchy | Project tonemapper |
| `exposure` | 0-no limit | Project exposure |
| `gamma` | 0-no limit | Project gamma |
| `material_maps` | Boolean | Enable material maps |

## Camera settings

Camera settings modify the camera active at the current test frame, if present.

### Camera and light management

| Setting | Values | Description |
| --- | --- | --- |
| `fov` | 1-170 degrees | Vertical field of view |
| `blade_amount` | Integer, 0-16 | Aperture blade count; timeline clamping permits up to 32 |
| `blade_angle` | -no limit to no limit, in degrees | Aperture blade rotation |
| `blade_stretch` | -1-1 | Blade-relative blur stretch; positive stretches up/down before blade rotation, negative stretches left/right |
| `light_management` | Boolean | Override project light-management settings for this camera |
| `cam_tonemapper` | `0` = none, `1` = Reinhard, `2` = ACES, `3` = Uchimura, `4` = Lottes, `5` = Hable, `6` = GT7 Curve, `7` = PBR Neutral, `8` = AgX, `9` = AgX Punchy | Camera tonemapper override |
| `cam_exposure` | 0-no limit | Camera exposure override |
| `cam_gamma` | 0-no limit | Camera gamma override |

### Rotation and shake

| Setting | Values | Description |
| --- | --- | --- |
| `rotate` | Boolean | Enable rotation around a point |
| `rotate_distance` | 1-no limit | Distance from the rotation point |
| `rotate_angle_xy` | -no limit to no limit, in degrees | Rotation around the point in the XY plane |
| `rotate_angle_z` | -no limit to no limit, in degrees | Rotation around the point's Z axis |
| `shake` | Boolean | Enable camera shake |
| `shake_mode` | `0` = rotational, `1` = positional | Camera shake mode |
| `shake_strength_x` | 0-no limit | X-axis shake strength |
| `shake_strength_y` | 0-no limit | Y-axis shake strength |
| `shake_strength_z` | 0-no limit | Z-axis shake strength |
| `shake_speed_x` | 0-no limit | X-axis shake speed |
| `shake_speed_y` | 0-no limit | Y-axis shake speed |
| `shake_speed_z` | 0-no limit | Z-axis shake speed |

### Depth of field

| Setting | Values | Description |
| --- | --- | --- |
| `dof` | Boolean | Enable depth of field |
| `dof_depth` | 0-`distance` | Focus depth |
| `dof_range` | 0-no limit | In-focus range around the focus depth |
| `dof_fade_size` | 0-no limit | Transition size into the blurred region |
| `dof_blur_size` | 0-0.1 | Blur size |
| `dof_blur_ratio` | -1-1 | Screen-aligned anamorphic blur ratio; positive stretches up/down, negative stretches left/right |
| `dof_blade_curvature` | 0-1 | Blade edge curvature; 0 is straight and 1 is circular |
| `dof_bias` | 0-10 | Depth-of-field bokeh bias |
| `dof_threshold` | 0-no limit | HDR highlights threshold |
| `dof_gain` | 0-no limit | Highlights strength |
| `dof_fringe` | Boolean | Enable depth-of-field color fringing |
| `dof_fringe_angle_red` | -no limit to no limit, in degrees | Red fringe direction |
| `dof_fringe_angle_green` | -no limit to no limit, in degrees | Green fringe direction |
| `dof_fringe_angle_blue` | -no limit to no limit, in degrees | Blue fringe direction |
| `dof_fringe_red` | 0-no limit | Red fringe offset |
| `dof_fringe_green` | 0-no limit | Green fringe offset |
| `dof_fringe_blue` | 0-no limit | Blue fringe offset |

### Bloom and lens dirt

Bloom is calculated from scene-linear HDR color before tone mapping. Use `--pass bloom_threshold` to inspect the extracted highlights and `--pass bloom_blur` to inspect the final blurred contribution, including blade streaks. Both debug passes use a fixed display curve so HDR values remain visible.

| Setting | Values | Description |
| --- | --- | --- |
| `bloom` | Boolean | Enable camera bloom |
| `bloom_threshold` | 0-no limit | Bloom brightness threshold |
| `bloom_transition` | 0-no limit | Distance around the threshold over which bloom fades in; 0 produces a hard cutoff |
| `bloom_intensity` | 0-no limit | Bloom intensity |
| `bloom_radius` | 0-no limit | Bloom radius |
| `bloom_ratio` | 0-1 | Bloom anamorphic ratio |
| `bloom_blend` | Color integer | Bloom tint color |
| `lens_dirt` | Boolean | Enable the lens-dirt overlay |
| `lens_dirt_bloom` | Boolean | Include bloom in lens dirt |
| `lens_dirt_glow` | Boolean | Include material glow in lens dirt |
| `lens_dirt_radius` | 0-3 | Lens-dirt blur radius |
| `lens_dirt_intensity` | 0-2 | Lens-dirt intensity |
| `lens_dirt_power` | 1-5 | Lens-dirt response power |

### Color correction and grain

| Setting | Values | Description |
| --- | --- | --- |
| `color_correction` | Boolean | Enable camera color correction |
| `contrast` | 0-no limit | Contrast adjustment |
| `brightness` | -no limit to no limit | Brightness adjustment |
| `saturation` | 0-no limit | Saturation multiplier |
| `vibrance` | 0-no limit | Vibrance adjustment |
| `color_burn` | Color integer | Color-burn tint |
| `grain` | Boolean | Enable film grain |
| `grain_strength` | -1-1 | Film-grain strength |
| `grain_saturation` | 0-1 | Film-grain saturation |
| `grain_size` | 1-10 | Film-grain size |

### Vignette, chromatic aberration, and distortion

| Setting | Values | Description |
| --- | --- | --- |
| `vignette` | Boolean | Enable vignette |
| `vignette_radius` | 0-1 | Vignette radius |
| `vignette_softness` | 0-1 | Vignette edge softness |
| `vignette_strength` | 0-1 | Vignette strength |
| `vignette_color` | Color integer | Vignette color |
| `ca` | Boolean | Enable chromatic aberration |
| `ca_blur_amount` | 0-1 | Chromatic-aberration blur amount |
| `ca_distort_channels` | Boolean | Distort the individual color channels |
| `ca_red_offset` | 0-no limit | Red channel offset |
| `ca_green_offset` | 0-no limit | Green channel offset |
| `ca_blue_offset` | 0-no limit | Blue channel offset |
| `distort` | Boolean | Enable lens distortion |
| `distort_repeat` | Boolean | Repeat edge pixels outside the distorted image |
| `distort_zoom_amount` | Greater than 0, up to no limit | Distortion zoom multiplier |
| `distort_amount` | -no limit to no limit | Signed lens-distortion amount |

### Output size

| Setting | Values | Description |
| --- | --- | --- |
| `size_use_project` | Boolean | Use the project output dimensions for this camera |
| `size_keep_aspect_ratio` | Boolean | Preserve aspect ratio when changing a custom camera size |
| `width` | Integer, 1-no limit | Custom camera output width in pixels |
| `height` | Integer, 1-no limit | Custom camera output height in pixels |
