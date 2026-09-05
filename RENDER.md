**Note:** This document is meant as a reference for agents debugging rendering features.

# Render test settings

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
| `distance` | 1,000-100,000 | Far render distance |
| `ssao` | Boolean | Enable screen-space ambient occlusion |
| `ssao_radius` | 0-256 | SSAO sampling radius |
| `ssao_power` | 0-no limit | SSAO strength |
| `ssao_color` | Color integer | SSAO tint color |
| `ssao_always_visible` | Boolean | Apply SSAO to all diffuse lighting instead of ambient lighting only |
| `shadows` | Boolean | Enable shadows |
| `shadows_sun_size` | 256, 512, 1024, 2048, 4096, or 8192 | Sun shadow-map resolution; 8192 is offered only when supported by the GPU |
| `shadows_spot_size` | 256, 512, 1024, 2048, 4096, or 8192 | Spot-light shadow-map resolution; 8192 is offered only when supported by the GPU |
| `shadows_point_size` | 256, 512, 1024, 2048, 4096, or 8192 | Point-light shadow-map resolution; 8192 is offered only when supported by the GPU |
| `shadows_transparent` | Boolean | Let transparent textures affect shadow maps |
| `subsurface_samples` | Integer, 0-32 | Subsurface-scattering quality/sample count |
| `subsurface_highlight` | 0-1 | Subsurface highlight amount |
| `subsurface_highlight_strength` | 0-no limit | Subsurface highlight strength |
| `indirect` | Boolean | Enable indirect lighting |
| `indirect_precision` | 0-1 | Indirect-lighting buffer precision/scale |
| `indirect_blur_radius` | 0-5 | Indirect-lighting blur radius |
| `indirect_strength` | 0-no limit | Indirect-lighting strength |
| `reflections` | Boolean | Enable screen-space reflections |
| `reflections_precision` | 0-1 | Reflection buffer precision/scale |
| `reflections_thickness` | 0.1-no limit | Reflection ray thickness |
| `reflections_fade_amount` | 0-1 | Reflection edge/distance fade amount |
| `glow` | Boolean | Enable material glow |
| `glow_radius` | 0-no limit | Glow blur radius |
| `glow_intensity` | 0-no limit | Glow intensity |
| `glow_falloff` | Boolean | Enable the secondary glow falloff layer |
| `glow_falloff_radius` | 0-no limit | Secondary glow radius |
| `glow_falloff_intensity` | 0-no limit | Secondary glow intensity |
| `aa` | Boolean | Enable anti-aliasing |
| `aa_power` | 0-3 | Anti-aliasing strength |
| `opaque_leaves` | Boolean | Render leaves as opaque geometry |
| `liquid_animation` | Boolean | Enable animated liquid waves |
| `water_reflections` | Boolean | Enable water reflections |
| `block_emissive` | 0-no limit | Default block/material emissive strength |
| `block_subsurface` | 0-no limit | Default block/material subsurface radius |
| `glint_speed` | 0-no limit | Enchantment glint animation speed |
| `glint_strength` | 0-no limit | Enchantment glint strength |
| `texture_filtering` | Boolean | Enable mipmapped texture filtering |
| `transparent_block_texture_filtering` | Boolean | Apply texture filtering to transparent blocks |
| `texture_filtering_level` | Integer, 0-5 | Mipmap/texture-filtering level |
| `alpha_mode` | `0` = blend, `1` = hashed | Project transparency mode |
| `tonemapper` | `0` = none, `1` = Reinhard, `2` = ACES | Project tonemapper |
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
| `light_management` | Boolean | Override project light-management settings for this camera |
| `cam_tonemapper` | `0` = none, `1` = Reinhard, `2` = ACES | Camera tonemapper override |
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
| `dof_blur_ratio` | 0-1 | Anamorphic blur ratio |
| `dof_bias` | 0-10 | Depth-of-field bokeh bias |
| `dof_threshold` | 0-1 | Bokeh highlight threshold |
| `dof_gain` | 0-2 | Bokeh highlight gain |
| `dof_fringe` | Boolean | Enable depth-of-field color fringing |
| `dof_fringe_angle_red` | -no limit to no limit, in degrees | Red fringe direction |
| `dof_fringe_angle_green` | -no limit to no limit, in degrees | Green fringe direction |
| `dof_fringe_angle_blue` | -no limit to no limit, in degrees | Blue fringe direction |
| `dof_fringe_red` | 0-no limit | Red fringe offset |
| `dof_fringe_green` | 0-no limit | Green fringe offset |
| `dof_fringe_blue` | 0-no limit | Blue fringe offset |

### Bloom and lens dirt

| Setting | Values | Description |
| --- | --- | --- |
| `bloom` | Boolean | Enable camera bloom |
| `bloom_threshold` | 0-1 | Bloom brightness threshold |
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
