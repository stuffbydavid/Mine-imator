Prompt:

*Make a list of all Mine-imator rendering effects (refer to interface options and rendering code in GmProject) and document what a suite of benchmarking tests should feature to have full coverage, including special, obscure situations. The suite will be an animation project file with different effects and render setting "presets" applied during runtime/playback (to implement), executed in a headless mode using tests_run().*

# Rendering benchmark test coverage

Date: 2026-08-27  
Scope: standalone Windows GameMaker VM project under `GmProject`  
Harness: headless benchmark execution through `tests_run()`  
Artifact: one animation project whose scene/camera/background state changes over playback; global render-setting presets are applied by the benchmark harness at runtime

## Purpose

This document inventories Mine-imator's user-visible rendering effects and defines the scene fixtures, runtime presets, edge cases, outputs, and assertions needed for full benchmark coverage.

“Full coverage” here means:

- Every exposed render, camera, background, light, material, and object-appearance option reaches at least one non-default code path.
- Every boolean is tested both disabled and enabled.
- Every enum/mode is tested at least once.
- Numeric controls are exercised at zero/minimum, a representative value, and a high value when those states select materially different work.
- Dependency gates and important effect interactions are tested deliberately rather than by a full Cartesian product.
- Both visual correctness and timing data are captured.
- The benchmark is deterministic enough for image comparisons and repeatable timing analysis.

This is a static analysis and suite specification. No build or benchmark was run while preparing it.

## Primary source map

The effect inventory is based on these interface and render entry points:

- Project render UI: [`tab_properties_render.gml`](../GmProject/scripts/tab_properties_render/tab_properties_render.gml)
- Project defaults/persistence: [`project_reset_render.gml`](../GmProject/scripts/project_reset_render/project_reset_render.gml), [`project_save_render.gml`](../GmProject/scripts/project_save_render/project_save_render.gml), and [`project_load_render.gml`](../GmProject/scripts/project_load_render/project_load_render.gml)
- Camera UI: [`tab_frame_editor_camera.gml`](../GmProject/scripts/tab_frame_editor_camera/tab_frame_editor_camera.gml)
- Background UI/defaults: [`tab_properties_background.gml`](../GmProject/scripts/tab_properties_background/tab_properties_background.gml) and [`project_reset_background.gml`](../GmProject/scripts/project_reset_background/project_reset_background.gml)
- Per-object material/color/appearance: [`tab_frame_editor_material.gml`](../GmProject/scripts/tab_frame_editor_material/tab_frame_editor_material.gml), [`tab_frame_editor_color.gml`](../GmProject/scripts/tab_frame_editor_color/tab_frame_editor_color.gml), and [`tab_timeline_editor_appearance.gml`](../GmProject/scripts/tab_timeline_editor_appearance/tab_timeline_editor_appearance.gml)
- Lights: [`tab_frame_editor_light.gml`](../GmProject/scripts/tab_frame_editor_light/tab_frame_editor_light.gml)
- High-quality pipeline: [`render_high.gml`](../GmProject/scripts/render_high/render_high.gml), [`render_start.gml`](../GmProject/scripts/render_start/render_start.gml), and [`render_post.gml`](../GmProject/scripts/render_post/render_post.gml)
- Low-quality flat/shaded pipeline: [`render_low.gml`](../GmProject/scripts/render_low/render_low.gml)
- Current harness: [`tests_run.gml`](../GmProject/scripts/tests_run/tests_run.gml)
- Existing animation fixture: [`test_project.miproject`](test_project/test_project.miproject)

## Complete rendering-effect inventory

### Project render settings

| Effect or control | User-facing parameters and modes | Main render path | Required coverage |
|---|---|---|---|
| Render samples | `project_render_samples`, UI range 1–256; built-ins use 24 or 128 | Temporal accumulation in `render_high`, `render_high_samples_add`, `render_high_samples_unpack` | 1, 2, 24, 128; optional 256 soak; static and moving content |
| Render distance | 1,000–100,000 in UI | Projection, fog limits, sun cascades, visibility | Near cutoff, cascade boundaries, distant large object, 1,000/default/high |
| Temporal AA | Off/on and power 0–3 | `render_high_update_taa` | Off, on at 1, power 0 and 3; thin lines, foliage, moving camera, hashed alpha |
| SSAO | Off/on, radius 0–256, power 0–unbounded, color | `render_high_ssao` and per-object AO mask | Radius 0/default/high; power 0/default/high; black and colored AO; object opt-out |
| Shadows | Global off/on | `render_high_shadows` | Off/on with every light class and with SSAO both off/on |
| Sun shadow resolution | 256, 512, 1024, 2048, 4096, and 8192 where exposed/supported | Three cascade surfaces | 256 and 2048 in regular runs; 4096/8192 capability/soak run |
| Spot shadow resolution | Same selectable sizes | Spot shadow surface | 256/default/high with cone-edge geometry |
| Point shadow resolution | Same selectable sizes | Six-face atlas path | 256/default/high with cubemap-seam geometry |
| Transparent shadows | Off/on | Shadow caster alpha hashing via `project_render_shadows_transparent` | Opaque, cutout, blended, and hashed casters; on/off |
| Subsurface scattering | Samples 0–32, highlight 0–1, highlight strength 0–unbounded | `render_high_subsurface_scatter` | Samples 0, 1, 7, 32; neutral and unequal RGB radii; highlight boundaries |
| Indirect lighting | Off/on, precision 0–1, blur radius 0–5, strength 0–unbounded | `render_high_indirect` ray trace/resolve/optional blur | Precision 0/default/high; blur 0 and nonzero; strength 0/default/high; shadows dependency |
| Screen-space reflections | Off/on, precision 0–1, fade 0–1, thickness 0.1–unbounded | `render_high_reflections` | Rough/metal material grid, screen edges, off-screen fallback, thickness and fade boundaries |
| Glow | Off/on, radius, intensity | `render_high_glow` | Zero/default/high radius and intensity; opaque and transparent sources |
| Glow falloff | Off/on, secondary radius and intensity | Second `render_high_glow(..., true)` call | Off/on; normal glow only, falloff only by zeroing primary, and both together |
| Texture filtering | Off/on | Per-object texture state | Pixel art close-up and receding oblique textures |
| Transparent-block filtering | Off/on while filtering is enabled | Transparent block texture state | Water/glass/leaves at close and oblique angles |
| Mipmap/filter level | 0–5 | `texture_set_mipmap_level` | 0, 1, 5 on high-frequency texture and distant scenery |
| Global alpha mode | Blended or hashed | `render_alpha_hash` and participating shaders | Both modes with layered transparency and temporal samples 1/24 |
| Tone mapper | None, Reinhard, ACES | `render_high_tonemap` | All three on HDR-like bright, dark, and saturated content |
| Exposure | 0–unbounded | Tone-map shader | 0, 1, high; near-black and emissive content |
| Gamma | 0–unbounded in UI | Tone-map/lighting shaders | 2.2 reference, low nonzero, high, and zero robustness case for NaN/divide handling |
| Material maps | Off/on | Material and normal texture selection | Manual scalar material, SEUS map, LABPBR map, missing/default maps, normal map |
| Bending style | Blocky or realistic | Generated/bent model geometry | Both styles on animated character/bodypart bends |
| Opaque leaves | Off/on | Block/scenery alpha behavior | Dense leaves against sky, shadows, SSAO, filtering, and fog |
| Liquid animation | Off/on | Animated water/lava textures/waves | Water and lava, frozen and animated, several playback times |
| Water reflections | Off/on | Water-specific reflection behavior | Water plane with reflected near object, sky fallback, and fog |
| Default block emissive | 0–unbounded | Default block material | 0, 1, high on lava/emissive blocks and bloom/glow interactions |
| Default block subsurface radius | 0–unbounded | Default block SSS material | 0, default, high on translucent/cutout blocks |
| Global glint speed | 0–unbounded | Glint shader timing | 0, 1, high |
| Global glint strength | 0–unbounded | Glint contribution | 0, 1, high |
| Built-in render presets | Performance, Balanced, Extreme | `.mirender` files and project render UI | Run exact built-ins; do not replace them with approximations |

### Direct light and material response

| Effect or control | Parameters/modes | Required coverage |
|---|---|---|
| Sunlight | Background sunlight color, strength, angle and sky direction | Day/sunset/night, black sun color (sun pass skipped), hard and soft sampling, cascade transitions |
| Ambient light | Background ambient color | Black, neutral, strongly colored; with direct light off |
| Point lights | Color, size, range, fade size, diffuse strength, specular strength, per-light shadows | Hard (`size=0`) and soft; shadowed and shadowless; range/fade boundaries; black/colored; camera inside volume |
| Spot lights | Point-light controls plus cone radius and sharpness | Radius near 1 and 150; sharpness 0 and 1; object on cone edge; shadowed/shadowless |
| Shadowless light batching | Groups of at most 31 are submitted together | Exactly 30, 31, 32, and 62 visible shadowless lights to exercise batch boundaries |
| Roughness | 0–1 | 0, 0.5, 1 under sun, point, spot, indirect, and reflections |
| Metallic | 0–1 | 0 and 1 plus mid value, paired with roughness grid |
| Emissive | 0–unbounded | 0, default, high; bloom threshold crossing; indirect/glow coexistence |
| Normal maps | Off/default/custom | Flat normal, high-frequency custom normal, mirrored/negative-scale geometry |
| Material formats | None, SEUS, LABPBR | One validated texture set for each format, including emissive/material channel interpretation |
| Per-object SSS | Strength/radius, RGB radius multipliers, color | Neutral, red-biased, green/blue-biased, inherited parent/child values, zero/high strength |

### Camera and post-processing effects

Post order is significant: DOF, glow, glow falloff, bloom, lens dirt, chromatic aberration, distortion, color correction, film grain, vignette, and overlay.

| Effect or control | User-facing parameters and modes | Required coverage |
|---|---|---|
| Camera resolution | Use project size or custom width/height; keep aspect ratio | Project size, 16:9, portrait, ultrawide, odd dimensions, 1×1 robustness, runtime size change |
| FOV | 1–170° | Narrow, normal, extreme wide; reflection/fog/DOF and frustum edges |
| Aperture shape | Blade count 0–16 and angle | 0, 1, odd, even, 16; angle 0 and rotated; used by bloom streaks and DOF bokeh |
| Camera light management | Project values or camera override | Override toggle off/on, all tone mappers, animated exposure/gamma |
| Rotate around point | Enable, XY/Z angle, distance, look-at toggle | Orbit with look-at off/on, close/far distance, angle wraparound, billboard objects |
| Camera shake | Rotational/positional, XYZ strength and speed | Both modes, zero and nonzero axes, TAA while shaking |
| Depth of field | Focus depth, range, fade size, blur size | Foreground/in-focus/background depth chart; zero and high blur; focus crossing animated geometry |
| Advanced DOF | Blur ratio, bias, gain, threshold | Each non-default independently, then all combined; bright highlights and dark edges |
| DOF fringe | Enable, RGB angles, RGB strengths | Off/on, defaults, asymmetric angles/strengths, high-contrast depth edges |
| Bloom | Radius, intensity, threshold | Threshold 0/default/1; radius/intensity 0/default/high; small bright points and broad emissive surfaces |
| Bloom blade streaks | Bloom ratio, blade count/angle, blend color | Ratio 0, 0.5, 1; blade counts 0/1/5/10/16; angle 0/rotated; white/colored blend |
| Lens dirt | Texture, bloom source toggle, glow source toggle, radius, intensity, power | Missing texture, valid texture, bloom-only, glow-only, both, neither gate, zero/high parameters |
| Color correction | Contrast, brightness, saturation, vibrance, color burn | Each field alone, neutral identity, desaturation, negative brightness, high saturation/vibrance, colored burn, combined |
| Film grain | Strength −1..1, saturation 0..1, size 1–10 | Negative/positive strength, monochrome/color grain, size 1/10, deterministic same-marker repeat |
| Vignette | Radius, softness, strength, color | Radius/softness 0 and 1, strength 0/1, black and colored vignette, portrait aspect |
| Chromatic aberration | Blur amount, channel distortion toggle, RGB offsets | Blur 0/high, distortion off/on, zero/equal/asymmetric offsets, high-contrast border chart |
| Distortion | Repeat, zoom amount, signed distortion amount | Amount 0, positive, negative, high; zoom below/equal/above 1; repeat off/on and image-edge pattern |
| Camera color overlay | Generic camera opacity, emissive, mix, RGB add/sub/mul, HSB add/sub/mul | Each operator alone and a combined case; alpha less than 1; overlay before/after watermark behavior |
| Watermark | Export option off/on | Both states, including transparent-background export |

### Background and environment effects

| Effect or control | Modes/parameters | Required coverage |
|---|---|---|
| Background visibility/removal | Render background or transparent export | Opaque background and removed background; verify output alpha and alpha-fix paths |
| Custom 2D image | Stretch off/on | Small nonmatching image, exact-fit image, transparent image |
| Spherical background | Rotation | Seam visible to camera, poles, rotation animation |
| Box background | Box mapped off/on, rotation | Both UV layouts and all cube directions |
| Minecraft sky | Time and rotation | Day, sunrise, sunset, night, and wraparound animation |
| Sun and moon sprites | Custom texture, angle, scale; moon phases | Default/custom, min/large scale, multiple angles, all supported moon phases |
| Stars and night color | Derived from sky time | Night and twilight transitions with fog sky on/off |
| Twilight | Off/on | Sunrise/sunset facing toward and away from the light |
| Clouds | Off/on; normal, faded, flat; texture, speed, offset, height, size, thickness, color | Every mode; speed negative/zero/positive; thickness 0/high; camera below/inside/above cloud layer; custom texture |
| Ground | Off/on; color, material, and normal textures | Default/manual material, animated texture, water ground, grazing camera, below-ground camera |
| Biome tint | Preset biome and manual grass/foliage/dry foliage/water/leaf colors | Representative warm/cold biomes and distinct manual channel colors on all affected block types |
| Sky/sun/ambient/night colors | Independent colors | Neutral and strongly separated diagnostic colors |
| Fog | Off/on; affect sky; automatic/custom fog and object colors; distance, size, height | Camera before/inside/after fog, height boundary, sky on/off, custom colors, per-object fog opt-out, transparent background |
| Wind | Off/on; speed, strength, direction, directional speed/strength | Off, static bend, animated wind, directional gust; object influence 0/1; terrain wind on/off |
| Texture animation speed | Signed/unbounded | Negative, zero, 1, high on water, lava, and another animated block |

### Per-object appearance and visibility effects

| Effect or control | Modes | Required coverage |
|---|---|---|
| Opacity | 0–1 | 0, partial, 1; overlapping layers and parent/child inheritance |
| RGB/HSB color operations | RGB multiply/add/subtract, HSB multiply/add/subtract | Each operation alone and inherited combinations |
| Color mix | Color and percentage | 0, 0.5, 1 and parent/child mix |
| Glow color | Per-object color | White and colored glow, inherited glow color |
| Glint | None, item, armor; custom texture, scale, speed, strength | Every mode, custom texture, zero/high speed and strength, transparent object |
| Blend mode | Normal, add, subtract, multiply, screen | Every mode over black, white, colored, and transparent backgrounds; overlapping order |
| Per-object alpha mode | Default, blended, hashed | All three under both global modes |
| Render depth | Negative, zero, positive | Intersecting transparent layers with at least three depth orders |
| Texture blur/filter | Independent object checkboxes | Every combination on pixel-art and transparent textures |
| Cast/receive participation | Per-object shadows and SSAO | On/off for caster, receiver, cutout, and transparent object |
| Wind participation | Wind and terrain-wind flags plus frame influence | Off/on and inherited influence |
| Glow participation | Glow, glow affected by texture, only-render-glow | Every combination, especially transparent and emissive objects |
| Fog participation | Per-object fog checkbox | On/off objects at identical distance |
| Backfaces | Off/on | Single-sided surface, inside cube, negative scale |
| HQ/LQ hiding | Independent flags | Flat/shaded/high export and include-hidden option |
| Billboard/face camera | Items, text, shapes, model shapes, particle forms | Camera orbit and FOV extremes |
| Hierarchical inheritance | Material/color/alpha/glow/SSS/wind values | Parent non-default, child identity, child override, deep hierarchy |

### Object-type-specific rendering

The fixture must contain every renderable timeline type, not merely cubes:

- Character and body parts, including deep hierarchy, bends, hidden shapes, and animated parts.
- Special block/model and imported model, including multiple shapes/materials and a block-format model.
- Block, item in 2D and 3D forms, and repeated scenery.
- Cube, cone, cylinder, sphere, surface, and path geometry.
- Text with antialiasing off/on, outline off/on/color, alignment variants, multiline and non-ASCII glyphs.
- Particle spawners producing sprite-sheet particles, template sprites, blocks, items, scenery, text, shapes, characters/bodyparts/models; billboard and non-billboard forms.
- Camera, background timeline, point light, and spot light.

Particles must use a custom seed. Include spawn/freeze/clear transitions, forward and reverse sprite animation, a missing-atlas fallback case, an attractor, directional force, and vortex force. Capture both a fixed particle count and a high-overdraw stress cloud.

### Render modes, passes, and export controls

| Control | Modes | Required coverage |
|---|---|---|
| View/render quality | Flat, shaded, high render | Smoke suite for all cases; full effect suite in high render; selected material/light/fog cases in flat and shaded |
| Diagnostic render pass | Combined, diffuse, specular, AO, shadows, indirect, indirect+shadows, reflections, depth U24, normal, material | One reference capture each; post effects must be gated off for non-combined passes |
| Effects toggle | View effects off/on | Camera and scene effects both states |
| Lights toggle | Flat/shaded behavior | Lights off/on with same scene |
| Particles toggle | Off/on | Fixed marker with populated spawner |
| Include hidden | Off/on | Hidden, HQ-hidden, and LQ-hidden objects |
| Background | Keep/remove | RGB and alpha validation |
| Watermark | Off/on | Opaque and transparent backgrounds |
| Output size/aspect | Project and per-camera | Landscape, portrait, ultrawide, odd dimensions, minimal dimensions |

## Animation project design

### General layout

Use one animation project with stable, named case markers. Each case should occupy either one instant keyframe or a short deterministic span when motion is essential. A dedicated camera should frame each fixture; its visibility switches must use instant transitions.

Do not infer cases from numeric marker ranges. Maintain a GML manifest used by `tests_run()`:

```gml
test_cases = [
    { id: "empty", marker: 0, modes: [e_view_mode.RENDER], presets: ["reference"] },
    { id: "material_grid", marker: 10, modes: [e_view_mode.SHADED, e_view_mode.RENDER], presets: ["reference", "balanced", "material_maps"] },
    // ...
];
```

The manifest is authoritative for case ID, marker/time, applicable modes, preset IDs, repetitions, warmups, resolution override, expected camera, and optional sample checkpoints. This replaces `camerafxstart`, `camerafxend`, `lightstart`, and `lightend`.

### Required fixture cases

| Case ID | Scene contents and purpose |
|---|---|
| `empty_alpha` | No world geometry; background kept/removed; validates clear color, alpha, sky, overlays, and surface initialization |
| `opaque_reference` | Simple opaque color chart, normal directions, depth steps, and a known light; basic regression reference |
| `geometry_types` | Every shape plus item, block, model, character, text, path, and scenery under one camera |
| `hierarchy_inheritance` | Deep parent/child material, color, alpha, glow, SSS, wind, hidden-shape and negative-scale combinations |
| `layered_alpha` | At least 8 overlapping textured layers covering every blend mode, all alpha modes, render-depth ordering, backfaces, and transparent background |
| `foliage_cutouts` | Dense leaves/grass with opaque-leaves, filtering, mip, hashed/blended alpha, shadows, SSAO, fog, wind, and TAA |
| `material_grid` | Roughness × metallic grid with emissive row, manual values, SEUS/LABPBR maps, normals, glancing highlights |
| `glint_glow` | Item/armor glint, custom texture, glow/glow-texture/glow-only, primary/falloff glow, transparent sources |
| `sss_chart` | Thin-to-thick objects with white and colored illumination, unequal RGB radii, highlight controls, occluder and background contrast |
| `ssao_chart` | Corners, cavities, touching/separated objects, thin geometry, object AO opt-out and transparent object |
| `indirect_room` | Enclosed colored room, occluders, opening to sky, emissive/high-albedo surfaces; tests precision, blur and leakage |
| `reflection_gallery` | Mirror/rough/metal surfaces, off-screen objects, screen edges, sky fallback, water, transparent foreground, thickness-sensitive gaps |
| `sun_cascades` | Objects crossing all three cascade boundaries, near/far thin casters, moving caster, sunlight black/nonblack |
| `point_shadow_seams` | Radial objects on each cubemap axis and seam, caster inside/outside range, camera inside light, hard/soft point light |
| `spot_cone_edges` | Geometry on cone center/edge/outside, sharp/soft falloff, hard/soft shadow, camera inside/outside cone |
| `shadowless_batch_boundary` | Identical scene rendered with 30, 31, 32, and 62 shadowless local lights |
| `fog_volume` | Depth and height staircase with identical fog-enabled/disabled objects; sky fog and custom colors |
| `wind_liquids` | Grass/leaves/vines or wind-capable model, terrain wind, water/lava, animation speed variants, water reflections |
| `particles_types` | Deterministic examples of every particle render form and lifecycle transition |
| `particles_overdraw` | Dense translucent sprite cloud plus dense 3D particle group for CPU/GPU stress separation |
| `dof_depth_chart` | Foreground, focus plane, background, bright bokeh points, transparency, DOF fringe, animated focus crossing |
| `bloom_lens_chart` | Subthreshold/threshold/superthreshold luminance patches, point lights, broad emissive surfaces, valid lens dirt texture |
| `post_color_chart` | Grayscale, skin-like, saturated primaries, gradients, black/white reference; color correction, grain, vignette |
| `ca_distort_grid` | Border-to-border grid and RGB edge chart; CA offsets/channel distortion and signed lens distortion/repeat |
| `camera_motion` | Translation, rotation, positional/rotational shake, subpixel detail; temporal stability and sample reset |
| `sky_backgrounds` | 2D, sphere, box, box-mapped backgrounds; day/twilight/night; sun/moon/stars; all cloud modes |
| `ground_biomes` | Ground material/normal/animated variants and diagnostic biome-tinted blocks/leaves/water |
| `visibility_output` | Normal hidden, HQ-hidden, LQ-hidden objects; particles; watermark; removed background; camera overlay |
| `render_distance` | Objects just before/at/after near chosen render distances, very large bounds crossing cutoff |
| `many_small_objects` | Thousands of simple objects with alternating textures/material states; GameMaker VM traversal/state stress |
| `large_scenery_repeat` | Large imported scenery and repeated scenery in X/Y/Z; geometry/submission stress |
| `many_characters` | Multiple complex animated characters/models and bodypart hierarchies; matrix/uniform/submesh stress |
| `all_effects` | Representative production scene with every compatible effect enabled together and several layered transparent/glowing elements |

Motion cases should have three checkpoints: before movement, during movement, and after stopping. This distinguishes steady-state temporal accumulation from sample invalidation and motion-related work.

## Runtime render-setting presets

Presets should be plain structs applied directly by the benchmark harness. Use exact built-in `.mirender` values for the three built-ins.

| Preset ID | Purpose and key settings |
|---|---|
| `reference` | 1 sample, AA off, SSAO/shadows/SSS/indirect/reflections/glow off, material maps off, blend alpha, filtering off; isolates base scene cost |
| `performance` | Exact `Data/Render/performance.mirender` values |
| `balanced` | Exact `Data/Render/balanced.mirender` values |
| `extreme` | Exact `Data/Render/extreme.mirender` values; scheduled/nightly only due 128 samples and large shadow maps |
| `effects_off_24` | 24 samples but all optional scene effects off; separates temporal cost from effects |
| `aa_blend_24` | 24 samples, AA on, global blended alpha, otherwise reference settings |
| `aa_hashed_24` | Same as above with global hashed alpha |
| `aa_power_edges` | Subcases power 0 and 3, 24 samples |
| `ssao_edges` | SSAO on with radius/power/color boundary subcases, shadows off to exercise AO-created shadow surface |
| `shadows_low` | Shadows on, all maps 256, transparent shadows off, other expensive effects off |
| `shadows_transparent` | Shadows on, standard maps, transparent shadows on, 24 samples |
| `shadows_high` | Sun/spot 4096, point 1024, soft lights; scheduled rather than per-commit |
| `sss_edges` | SSS sample subcases 0, 1, 7, 32 and highlight controls |
| `indirect_edges` | Indirect on with precision 0/default/high, blur 0/nonzero, strength 0/high; shadows on as required |
| `reflections_edges` | Reflections on with precision, thickness, and fade boundary subcases |
| `glow_primary` | Primary glow enabled; zero/default/high radius/intensity subcases |
| `glow_falloff` | Primary plus falloff glow with distinct radii/intensities |
| `material_maps` | Material maps on, filtering on, mip level 1 |
| `filter_edges` | Filtering off/on, transparent filtering off/on, mip 0/1/5 subcases |
| `minecraft_features` | Opaque leaves, liquid animation, water reflections, block emissive/SSS, blocky/realistic bend subcases |
| `tonemap_none` | None, exposure 1, gamma 2.2 |
| `tonemap_reinhard` | Reinhard with low/default/high exposure subcases |
| `tonemap_aces` | ACES with low/default/high exposure subcases |
| `numeric_zero_robustness` | Enabled effects with zero radius/intensity/power/precision/blur, exposure 0, gamma 0, light range/size/strength 0; correctness-only |
| `all_effects_sane` | Balanced-like settings plus glow falloff, material maps, transparent shadows, water reflections, camera FX from timeline |

Do not run every preset against every case. The case manifest must list only meaningful pairs. The built-in presets, `reference`, and `all_effects_sane` run across the production/stress cases; targeted edge presets run only on their diagnostic fixture.

## Required interaction coverage

The following combinations are easy to miss and must have explicit cases:

1. SSAO on while shadows are off. `render_high_ssao()` creates/clears the shared shadow surface differently in this state.
2. Indirect enabled in the preset while shadows are disabled. `render_start()` gates indirect through `render_shadows`; verify the effect is skipped cleanly and the manifest records the effective state.
3. Reflections with rough/metal materials, water reflections, fog, sky fallback, and transparent foreground layers.
4. SSS with sun, shadowed point, shadowed spot, colored light, no light, and samples set to zero.
5. Global blended alpha with a per-object hashed override, and global hashed alpha with a per-object blended override.
6. Transparent shadows off/on for blended, hashed, leaf-cutout, water, and glow-only casters.
7. TAA off/on across hashed alpha, moving foliage, camera shake, point-light softness, and stopped motion.
8. Glow primary/falloff with camera lens dirt sourcing glow only, bloom only, both, and neither.
9. Lens dirt enabled without a texture. `render_start()` disables the path unless `TEXTURE_OBJ` is non-null.
10. Camera effects with a diagnostic non-combined render pass. `render_start()` should gate them off.
11. Fog with sky fog off/on, custom object color off/on, per-object fog off, and removed background.
12. Material maps off/on with missing maps, normal maps, animated textures, manual emissive, and default block material values.
13. Opaque leaves with transparent filtering, transparent shadows, SSAO, fog, wind, and both alpha modes.
14. Water reflections with liquid animation off/on, fog, screen-space reflections, and background removal.
15. Every blend mode over both opaque and transparent destinations, with render-depth ordering and negative-scale/backface geometry.
16. Camera overlay alpha/color operations followed by watermark; test both opaque and transparent output.
17. Resolution/aspect change while effects are enabled, ensuring every cached surface is recreated to the right dimensions.
18. Effect settings changed while the camera matrix is unchanged. This must still invalidate temporal accumulation.

## Obscure and robustness situations

| Situation | Why it matters | Expected test behavior |
|---|---|---|
| Empty scene and no active camera | Exercises `render_camera == null`, camera-effect disabling, clears, and background-only composition | Completes without error; output dimensions/alpha are correct |
| Custom camera dimensions of 1×1, 1×N, odd sizes, portrait and ultrawide | Finds divide-by-size, half-texel, blur-kernel, and surface-allocation assumptions | No invalid surfaces or NaNs; visual checks limited for minimal sizes |
| Camera intersects geometry or lies below ground/inside cloud/fog/light | Stresses near-plane and inside-volume behavior | No full-screen inversion, clipping explosion, or invalid depth |
| Object exactly on sun cascade, spot cone, point-face seam, fog, and render-distance boundaries | Detects inequality/seam errors | Adjacent checkpoints remain continuous within tolerance |
| Zero-length/very thin surfaces and extreme negative/nonuniform scale | Stresses normals, culling, depth packing, backfaces | No NaN/black-frame propagation |
| Fully transparent object with glow-only or custom blend mode | Multiple passes make different discard/blend decisions | Intended glow visible; unrelated buffers remain uncontaminated |
| Black sunlight color while shadows remain enabled | `render_high_shadows()` uses color to decide whether the sun is active | Sun work/output is skipped without corrupting local lights/ambient |
| 31-to-32 shadowless light transition | Explicit internal batching boundary | Correct light sum and predictable one-batch cost step |
| Aperture blade count 0/1/odd/even with bloom ratio > 0 and blade angle 0 | Bloom streak math has special branching and potentially fragile zero-angle arithmetic | No divide error/NaN; defined fallback appearance |
| DOF range/fade/blur all zero | Degenerate CoC behavior | Identity or documented limit, never an invalid frame |
| Bloom/glow/lens radius or intensity zero while enabled | Enabled-but-no-op path still allocates/runs effects | Correct identity output; cost is separately visible |
| Reflection/indirect precision zero | Ray-step boundary | Completes deterministically without an unbounded loop |
| Gamma zero and exposure zero | UI permits zero; shaders may divide or exponentiate | Robustness result explicitly marked pass/fail; do not use as timing baseline |
| Grain negative strength and repeated render of same marker | Grain supports signed strength and seeds from background time | Same marker/preset produces stable deterministic image/hash |
| Missing/unready custom textures and particle atlas entries | Resource fallback paths are present in render code | No crash; documented fallback or skipped element |
| Surface recreation between repetitions | GameMaker surfaces are cached and format/size dependent | Cold allocation is measured separately; warm output matches |
| Timeline bool switch on the same marker as camera visibility | Effect booleans use instant semantics | Correct camera/effect selected with no one-frame lag |
| Reverse/zero texture animation speed and timeline rewind | Animated blocks/particles and benchmark marker jumps can retain state | Deterministic state after explicit reset/replay |
| Deep transparent hierarchy with inherited alpha/material values | Parent-child calculations differ by property | Expected accumulated/inherited values visible in diagnostic chart |
| Include-hidden plus HQ/LQ hiding | Three different visibility mechanisms interact with quality mode | Each named object appears only in intended outputs |
| Transparent background plus fog sky, watermark, vignette, distortion and CA | Post shaders may accidentally overwrite alpha | Alpha contract checked at corners and object edges |

## Headless harness requirements

### Replace hard-coded ranges

The current harness defines camera FX as markers 9–37 and light tests as 38–45. The current project places the main camera-FX keys at markers 30–59, so those ranges are already stale. Remove all range knowledge from `tests_run()` and use the manifest described above.

### Apply presets explicitly

Add a `tests_apply_render_preset(preset)` helper. It should:

1. Start from `project_reset_render()` defaults, then assign every `project_render_*` setting, `project_bend_style`, and relevant block/liquid/leaf/glint setting explicitly. A preset must not inherit accidental values from the previous preset.
2. Set `project_render_settings = ""` so the benchmark state is identified as runtime custom settings.
3. Apply dependent state such as `texture_set_mipmap_level(project_render_texture_filtering_level)`.
4. Rebuild/invalidate data that depends on changed settings only when necessary.
5. Force temporal invalidation with at least `render_samples = -1`, `render_samples_clear = true`, and `render_samples_done = false`.

The last step is mandatory. `render_update_samples()` automatically resets for camera-matrix, target-size, or missing-surface changes, but most render-setting changes leave those values untouched. Without explicit invalidation, a new preset can reuse samples accumulated under the previous preset.

Reset-before-overlay is also required for the shipped presets. Performance, Balanced, and Extreme each contain 44 render keys and omit the newer persisted `glint_speed` and `glint_strength` fields. Loading one directly over an earlier runtime preset would otherwise retain the earlier glint values. Starting from project defaults gives those omitted fields the deterministic value `1` while preserving the shipped values for every key the file defines.

### Reset animation deterministically

For each case/preset repetition:

- Set `timeline_marker` and `timeline_marker_previous` deliberately.
- Reset/replay particle spawners from a known point; require custom seeds.
- Set the random seed before animation and before rendering.
- Make background time/texture animation deterministic for the marker.
- Ensure the intended camera is the only visible render camera.
- Assert that asynchronous project resources have completed loading, retaining the existing loading-queue drain.
- Clear state left by previous modes, including `render_pass`, hidden/background/watermark/effects/particles/lights flags.

Jumping directly between distant timeline markers is not sufficient for particle or other history-dependent animation. The harness should either replay from the nearest reset checkpoint or load a deterministic snapshot.

### Separate cold and warm measurements

Record two classes:

- `cold`: surfaces/shaders/resources may allocate or initialize. Force `render_free()` or an equivalent safe surface invalidation before the case.
- `warm`: perform at least one unmeasured render, then collect 3–7 repetitions and report median and p95.

Do not mix cold and warm values into one average. Surface allocation time is already tracked separately; keep it separate in CSV and summaries.

### Limit irrelevant mode combinations

High-quality effects run only when the render quality is `e_view_mode.RENDER`; flat/shaded use `render_low()`. Running flat, shaded, and high for every marker triples work without improving effect coverage.

- Run a compact all-mode smoke subset for background, geometry/material, fog/light, particles, visibility, and overlay.
- Run high-quality-only cases for SSAO, shadows, SSS, indirect, reflections, TAA, glow, DOF, bloom, lens dirt, CA, distortion, and high render passes.
- Run flat vs shaded on light, fog, material-color, alpha, and HQ/LQ visibility fixtures.

### Capture temporal checkpoints

For TAA, hashed alpha, soft shadows, grain, and motion tests, support captures at sample counts 1, 2, 4, 8, 24, and final where applicable. A final-only PNG cannot reveal convergence regressions or sample-reset bugs.

### Output schema

At minimum, write one row per measured repetition with:

```text
RunId,CaseId,Marker,Mode,RenderPass,Preset,ColdWarm,Repetition,
Width,Height,SamplesRequested,SamplesRendered,GraphicsAPI,
Animate_ms,Total_ms,Render_ms,Surface_ms,Encode_ms,Other_ms,
RenderWorldCount,OutputFile,ImageHash,Status,Notes
```

Also save a run-level JSON manifest containing:

- Application/build identifier and project format.
- Graphics API, adapter/driver if available, OS, and surface maximum size.
- Exact effective preset values, not just the preset name.
- Case manifest revision and benchmark project hash.
- Warmup/repetition policy.
- Any skipped capability or allocation case and its reason.

The existing CSV literal `preset` must be replaced by the actual preset ID.

### Correctness assertions

Each case should fail loudly on:

- Startup/resource/shader/surface errors.
- Missing intended camera or unexpected active camera.
- Incorrect target dimensions.
- High-quality render ending before the requested sample count.
- Non-finite timing or parameter data.
- Empty/fully black output where the case declares visible content.
- Unexpected opaque alpha in removed-background cases.
- Image hash mismatch for deterministic exact cases.
- Perceptual/golden-image difference beyond a case-specific tolerance for GPU-sensitive effects.

Use exact hashes only for deterministic, same-API references. Use perceptual metrics and diagnostic crops for shadows, SSAO, ray-traced effects, grain, particles, and other GPU/precision-sensitive cases. Retain the output image for every failure.

## Coverage and scheduling tiers

### Per-change smoke

- `empty_alpha`
- `opaque_reference`
- `layered_alpha`
- `material_grid`
- `sun_cascades`
- one shadowed point and spot light
- `dof_depth_chart`
- `bloom_lens_chart`
- `post_color_chart`
- `particles_types`
- `all_effects`

Use `reference`, `performance`, and `balanced`, with one warmup and three warm repetitions at a modest fixed resolution.

### Nightly full coverage

All fixtures, targeted edge presets, all diagnostic render passes, resolution/aspect variants, sample checkpoints, 30/31/32/62 light boundaries, cold and warm measurements, and the `extreme` preset where allocations succeed.

### Scheduled stress/soak

- 256 samples.
- 8192 shadow maps when exposed and supported.
- 4K and ultrawide outputs.
- `many_small_objects`, `large_scenery_repeat`, `many_characters`, and `particles_overdraw` at several scale factors.
- Repeated runtime preset/resolution switches to detect surface leaks or stale cached state.

## Existing benchmark project status

The current project already contains useful starting fixtures named for:

- Reflections, transparency, color modes, and fog.
- Point lights, spot lights, and transparent shadows.
- AO and indirect lighting.
- Subsurface scattering.
- Camera effects.

It also contains examples such as blended/hashed transparent blocks, glow-only and texture-affected glow, AO/shadow opt-outs, color operations, water/lava, particles, scenery, multiple characters, and local lights.

It is not yet full coverage. Notable gaps or harness deficiencies include:

- No runtime render-preset loop or effective-setting record.
- Stale hard-coded marker ranges.
- No repetitions, warmup policy, or cold/warm separation.
- No explicit sample-cache invalidation between setting changes.
- No manifest-driven effect-to-case mapping.
- No complete environment/background, blend-mode, render-pass, output-alpha, resolution, light-batch-boundary, and object-type matrices.
- No automated correctness assertions or image baseline policy.

The existing assets and scenes should be retained where they satisfy a fixture, then reorganized behind stable manifest IDs rather than marker ranges.

## Definition of done

The suite has full coverage when:

1. Every row in the effect inventory maps to at least one case/preset pair and every enum value appears in the generated run manifest.
2. All required interaction and obscure-situation rows have an automated case.
3. Runtime preset switching cannot reuse old temporal samples or stale-size surfaces.
4. Particle, grain, animation, and camera state are deterministic for repeated identical runs.
5. Combined and every diagnostic render pass produce validated outputs.
6. Flat, shaded, and high paths are covered without blindly multiplying every case.
7. Cold allocation and warm steady-state timings are reported separately with repetitions.
8. Output alpha, dimensions, sample counts, errors, and images are automatically checked.
9. Built-in Performance, Balanced, and Extreme values are tested exactly as shipped.
10. The manifest and reports make skipped hardware-capability cases explicit rather than silently omitting them.
