Prompt:

*Make a list of Mine-imator rendering effects (refer to interface options and rendering code in GmProject) and document what a suite of benchmarking tests should feature to have reasonably good coverage of situations that animators will encounter, including some special, obscure situations. The suite will be an animation project file with different effects and render setting "presets" applied during runtime/playback (to implement), executed in a headless mode using dev_mode_benchmarks(). Focus on testing features that are affected by shader/render call optimization work, not new workflow/UI additions.*

# Rendering benchmark coverage v2

## Goal and scope

This is the practical test plan for one deterministic `.miproject` driven by
`dev_mode_benchmarks()` in a fully headless run. It targets performance and
correctness regressions caused by shader, render-call, surface, batching, and
animation-update optimisation work.

It is deliberately **not** a UI, editor-workflow, import-dialog, or preset-file
test plan. Presets are applied by the harness while the project plays; they
must not rely on opening an interface window.

The suite should answer three questions for a representative animator scene:

1. Did an optimisation reduce steady-state render cost?
2. Does it still render the scene correctly when draw state, visibility,
   lighting, and camera animation change?
3. Is time attributed to animation, rendering, surface work, or export work
   correctly?

The high-quality render path is the priority. Flat and shaded runs remain small
smoke tests because they exercise `render_low()` and quality-specific
visibility, but do not need every high-quality effect combination.

## Source-derived rendering inventory

The inventory is based on project render actions plus `render_start`,
`render_low`, `render_high_*`, `render_post`, `render_world_tl`, and
`render_world_block` in `GmProject/scripts`.

### Quality paths and diagnostic outputs

| Area | Choices that need coverage | Optimisation relevance |
|---|---|---|
| View quality | Flat, Shaded, High render | Flat/shaded use `render_low`; high render allocates multi-pass surfaces and invokes the full shader set. |
| Output pass | Combined, Diffuse, Specular, AO, Shadows, Indirect, Indirect Shadows, Reflections, Depth U24, Normal, Material | Pass selection gates work and changes surface use; it is a useful probe for cached draw state. |
| Sampling | 1 sample and a representative multi-sample run (24); TAA off/on and low/high power | Exercises temporal jitter, accumulation, and invalidation without making every test prohibitive. |
| Output shape | Fixed landscape reference, portrait/ultrawide, and one odd-sized target | Surface creation, half-pixel calculations, and post-process kernels are dimension-sensitive. |

### Geometry, material, and draw-state effects

`render_world_tl` selects shader inputs and GPU state from timeline and
project values. These are the most important coverage dimensions for
render-call and shader-permutation optimisation:

| State/effect | Scene fixture required |
|---|---|
| Object types | Blocks, scenery, character/model with multiple shapes, item, text, primitive shapes, and particles. |
| Texture identity/filtering | Repeated identical textures followed by alternating textures; nearest/filtered textures, mip levels, and a transparent texture. |
| Alpha | Opaque, cutout/leaves, blended layers, hashed alpha, and per-object override of the global alpha mode. |
| Blend mode and render depth | Normal plus add, subtract, multiply, and screen; three overlapping transparent layers with differing render depths. |
| Culling | Backfaces on/off, an inside-facing room, and a negatively scaled or mirrored surface. |
| Material | Roughness/metallic grid, emissive object, normal/material-map object, and ordinary scalar-material object. |
| Colour | Neutral object plus RGB/HSB/mix colour operations, including inherited parent values and a child override. |
| Glow and glint | Ordinary glow, texture-affected glow, glow-only object, coloured glow, item/armour glint, and no glint. |
| Environment participation | Fog and wind each enabled and disabled per object; terrain wind on foliage; water/lava texture animation. |
| Minecraft-specific branches | Water, lava, foliage/grass, leaves, animated blocks, opaque-leaves option, water reflections, and a large repeated scenery build. |

The project should contain both a **batch-friendly** arrangement (many objects
with the same vbuffer, texture, and state) and a **state-churn** arrangement
(the same approximate triangles, but alternating texture/filter/culling/alpha/
material/glow state). Comparing those two is the clearest benchmark for state
deduplication and submission ordering changes.

### Lighting and high-quality effects

| Effect family | Required representative situations |
|---|---|
| Sun and ambient | Day-like directional light, strongly coloured ambient, and an object crossing a sun-cascade boundary. |
| Point lights | One hard shadowed light, one soft shadowed light, one shadowless light, coloured lights, and a camera inside a light range. |
| Spot lights | Shadowed and shadowless cones, with geometry crossing the sharp cone edge. |
| Shadow maps | Shadows off/on; transparent shadows off/on; a modest map-size baseline and a high-map-size scheduled stress case. |
| SSAO | Off/on, zero/normal radius, coloured AO, concave geometry, and a per-object AO opt-out. |
| Indirect light | Off/on with shadows enabled; zero/non-zero blur radius and a reflective/occluded corner. |
| Screen-space reflections | Off/on over rough and metallic material, water, a screen edge, fog, and a sky fallback. |
| Subsurface scattering | Disabled, a small non-zero sample count, and a higher sample count; thin/translucent-looking coloured subjects. |
| Glow | Primary glow and glow falloff separately and together, with opaque and transparent sources. |

`render_start` makes some combinations conditional: indirect lighting depends
on shadows, camera effects are disabled for non-combined diagnostic passes, and
lens dirt requires a valid texture plus a bloom or glow source. The manifest
must record both requested and effective state, so a gated effect is never
mistaken for a measured one.

### Camera, post-processing, and background

Post-processing is ordered as DOF, glow, glow falloff, bloom, lens dirt,
chromatic aberration, distortion, colour correction, grain, vignette, then
camera colour/watermark overlay. A compact chart scene should cover:

- Foreground, focus plane, background, and bright bokeh points for DOF.
- Sub-threshold and bright emissive patches for bloom and lens dirt.
- A high-contrast border grid for chromatic aberration and distortion.
- Greyscale, primary colours, black, white, and gradients for colour
  correction, tonemapping, exposure, gamma, grain, and vignette.
- Transparent-background and ordinary-background captures, including fog and
  a camera overlay. This detects accidental alpha loss in post passes.
- A camera-texture object, if supported by the fixture, to exercise camera
  surface scheduling. Avoid a self-referential camera feedback loop.

The environment chapter needs a fog volume/height transition, sky-fog off/on,
a cloud/sky background, and ground behind transparent water. It need not
exhaustively test every decorative sky setting; its purpose is to create real
depth, overdraw, and reflection inputs.

### Animation and visibility

The benchmark must animate more than camera position. For selected markers it
should include rapid character/model transforms, a moving camera, a light
crossing objects, wind/liquid texture motion, particles, and a camera focus
change. Take checkpoints before movement, while moving, and after stopping.
That distinguishes a steady render from animation work and temporal-sample
invalidations.

Visibility is a first-class correctness fixture:

- A child object switches `visible` off at frame 4 while its parent remains
  visible.
- A second object has normal, HQ-hidden, and LQ-hidden intervals.
- The active camera is invisible until a later marker; frame 0 must therefore
  use the correct visible camera rather than the last cached camera state.
- Include a particle emitter and a light that turn on and off at exact markers.

Run those markers in every quality smoke test. This protects the timeline state
updates that headless marker jumps depend on, rather than only testing a fully
played editor session.

## Proposed single-project chapters

Each chapter has a named camera and stable marker range. The runtime manifest
maps names to markers; `dev_mode_benchmarks()` must not infer behavior from
hard-coded marker ranges.

| Chapter | Contents | Principal coverage |
|---|---|---|
| `calibration` | Empty/background-only frame and a small opaque reference set | Clear/setup overhead, alpha contract, baseline timing. |
| `submission_batching` | Hundreds/thousands of repeated opaque blocks/scenery, then a same-sized alternating-state grid | Vbuffer/texture/state reuse versus state churn. |
| `material_alpha` | Material grid, cutout foliage, layered glass/water, blend modes, glow/glint, negative-scale backface prop | Shader permutations, blend/cull changes, transparent ordering. |
| `minecraft_motion` | Water/lava, grass/leaves wind, repeated scenery, animated character/model/item/text | Minecraft render branches and animation traversal. |
| `visibility_camera` | Parent/child visibility keys, HQ/LQ hiding, camera switches, exact marker transitions | Timeline update correctness in headless mode. |
| `lights_shadows` | Sun cascade prop, shadowed/shadowless point and spot lights, transparent casters | Shadow surfaces, light batching, direct-light passes. |
| `screen_space` | Occlusion corner, reflective water/metal, SSS subject | SSAO, indirect, SSR, SSS surfaces and resolve passes. |
| `particles_overdraw` | Deterministically seeded sparse then dense particle sets | Dynamic submissions and transparent overdraw. |
| `camera_post` | Depth, luminance, colour, and border charts plus moving camera/focus | DOF, glow/bloom, tone/post passes, TAA invalidation. |
| `production_mix` | Short action composition combining scenery, characters, water, lights, particles, and camera motion | Realistic integration benchmark with several effects active together. |

For every chapter, retain one **static warm** marker. Dynamic chapters add a
small number of named movement markers rather than benchmarking every frame of
a minute-long animation.

## Runtime render presets

Apply presets as complete structs in the benchmark harness. First restore
render defaults, then assign every relevant project render setting; never let a
preset inherit a value from the previous one. Record complete effective values
in the output manifest.

| Preset | Use | Suggested scope |
|---|---|---|
| `flat_smoke` | Flat quality baseline | Calibration, material/alpha, visibility, and production mix. |
| `shaded_smoke` | Shaded low path with fog/lights | Same compact set as flat. |
| `high_reference` | High quality, 1 sample, optional high effects off | All chapters; establishes geometry and base-surface cost. |
| `high_temporal` | High quality, 24 samples, TAA on | Static and moving markers in material/alpha, motion, visibility, and post chapters. |
| `high_shadows_ao` | Shadows, transparent shadows, and SSAO on | Lighting and alpha chapters. |
| `high_screen_space` | Shadows, indirect, reflections, and SSS on | Screen-space and production chapters. |
| `high_post` | High quality plus camera/post stack | Camera/post and production chapters. |
| `high_minecraft` | Filtering/mips, material maps, leaves, liquid animation, water reflections | Minecraft motion and production chapters. |
| `diagnostic_passes` | One capture per non-combined render pass | A small reference scene only. |
| `stress_extreme` | Large shadow surfaces, higher SSS/samples, high resolution | Scheduled run only; not per-change. |

Do not take a Cartesian product of every preset and every chapter. Run
`high_reference` and the production mix broadly, then pair targeted presets
only with fixtures that can visibly exercise them.

When a preset changes, force temporal invalidation before capture. Changing
effect settings while camera matrices remain constant must not retain samples
accumulated under the preceding preset. A warm-up render after a preset or
target-size change is also required before recording warm timings.

## Measurements and run protocol

For each `(case, marker, preset, quality)` pair:

1. Reset timeline-dependent state deliberately. Set
   `timeline_marker_previous` so the selected marker updates; reset/replay
   seeded particles from a known checkpoint rather than relying on a random
   jump.
2. Apply the full preset and record its effective values.
3. Capture one **cold** result when surface allocation/recreation is explicitly
   under test. Keep it separate from normal performance comparisons.
4. Render one unmeasured warm-up, then collect at least three warm repetitions
   and report median and p95. Use the same output size and sample count within
   a comparison.
5. For multi-sample high quality, loop `export_update()` until it reports
   done; record samples requested and completed. Do not classify a partial
   accumulation as a final frame.

The CSV needs one row per measured export with at least:

```text
RunId,CaseId,Marker,Preset,Quality,RenderPass,ColdWarm,Repetition,
Width,Height,SamplesRequested,SamplesCompleted,
Total_ms,Animate_ms,Render_ms,Surface_ms,Encode_ms,Other_ms,
OutputFile,ImageHash,Status,Notes
```

`Other_ms` should be the residual after timed phases, so the reported
relationship is auditable:

```text
Total_ms = Animate_ms + Render_ms + Surface_ms + Encode_ms + Other_ms
```

Log raw phase boundaries and this residual. A negative residual or a large
changing residual is a measurement bug or uninstrumented phase, not a rendering
conclusion. Surface creation/reuse must be attributed separately: surface cost
must not silently inflate or disappear into render time.

## Correctness checks alongside timings

Timing alone is insufficient for shader-call optimisation. Save one image for
every measured case and use these checks:

- Exact image hashes for static deterministic reference cases on the same
  graphics stack.
- Tolerant/pixel-region comparisons for shadows, AO, reflections, particles,
  grain, and temporal accumulation.
- Targeted crops for the visibility child, active camera region, alpha corners,
  water reflection, transparent-shadow caster, and state-churn material grid.
- Assertions for output dimensions, requested/final samples, expected active
  camera, and expected visible/hidden object IDs.
- Explicit skip/fail records for missing resource, unavailable surface, shader,
  or unsupported-size errors; never silently omit a failed case.

The following obscure cases are worth retaining even if they are not daily:

| Case | Reason |
|---|---|
| 30, 31, and 32 visible shadowless point lights | Exercises the renderer's light-batch boundary. |
| Object on a sun cascade, point-light atlas face, spot-cone, fog-height, and render-distance boundary | Finds off-by-one and depth/seam regressions. |
| Glow-only fully transparent object | Different passes make different visibility/discard choices. |
| Per-object hashed alpha under global blend, and the inverse | Detects state-cache leakage between objects. |
| Water with fog, transparent foreground, animated liquid, and reflections | Combines block-specific, transparent, screen-space, and background paths. |
| Hidden child with unchanged visible parent; camera key at frame 0 | Protects headless timeline visibility updates. |
| Alternating state grid after a large batched grid | Detects stale texture/blend/cull/shader state after an optimisation. |
| Odd target dimensions and a resize between cases | Detects stale/reused post-process surfaces. |
| Timeline rewind or direct jump with particles/liquid animation | Detects history left behind by marker-based benchmarking. |

## Coverage tiers

### Per-change smoke

- `flat_smoke`, `shaded_smoke`, `high_reference`, and `high_temporal`.
- Calibration, submission batching, material/alpha, visibility/camera, one
  light/shadow frame, one screen-space frame, one post frame, and production
  mix.
- One warm-up plus three warm repetitions at fixed modest resolution.

### Nightly coverage

- All chapters and targeted presets.
- One result for each diagnostic render pass.
- Cold and warm surface results, portrait/ultrawide, 30/31/32-light boundary,
  and the obscure-case table.

### Scheduled stress

- `stress_extreme`, high resolution, larger repeated scenery/particle counts,
  and long multi-sample exports.
- Repeated preset and resolution switches to reveal surface leaks, stale cached
  state, or non-deterministic output.

## Definition of useful coverage

The suite is sufficiently covered when each source-derived effect family has a
named case/preset pair, the batch-friendly and state-churn scenes are compared,
all three quality paths have smoke coverage, and every high-quality subsystem
has both an isolated fixture and a production-mix run. A result is valid only
when its timeline state, effective preset, sample completion, output image, and
phase timing are recorded together.
