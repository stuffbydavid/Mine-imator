Prompt:

*Investigate performance optimizations and opportunities for reducing repeated draw calls, limiting the scope to changes in CppProject only. The focus should be on improving the rendering speed of 3D scenes with many layered effects in render_high(). New proposed shader functionality or format changes should be compatible with both D3D11 and OpenGL 4.3-4.0/GLSL 1.50 modes, and on low-to-high end cards.
Ignore warnings about files under Generated/ being temporary, overwritten or risky - for this task treat them as hand-written and fully editable parts of the software, much like the code under Render/, Asset/, Type/ etc.*

# Rendering performance analysis

## Scope and assumptions

This analysis is limited to source and shader files under `CppProject`. No outside project, documentation, benchmark, build, or application run was consulted.

For this task, every file under `CppProject/Generated` is treated as hand-written, first-class, fully editable software, on the same footing as code under `Render`, `Asset`, `Type`, and `Gml`. Changes may be implemented directly at the active `Generated` call sites. Regeneration or overwrite concerns are intentionally out of scope and do not affect priority, design, or implementation location.

The compatibility floor used throughout is:

- D3D11, including the feature-level 10 fallback requested by `GraphicsApiHandler`.
- OpenGL using the existing GLSL `150 core`, GLSL 4.00, and GLSL 4.30 modes.
- Low-to-high-end GPUs. The baseline recommendations therefore do not require compute shaders, image load/store, SSBO-only data paths, bindless resources, or GPU-driven indirect rendering.

## Executive summary

`render_high()` is dominated by two multiplicative costs: repeated traversal and drawing of the same scene, and repeated movement or filtering of full-resolution render surfaces. A scene is redrawn for color, depth/normal, material/emissive, glint, scene masks, each class of lighting, AO masks, subsurface data, fog, DoF depth, and glow sources. Each shadowed point light adds another six caster traversals. Many effects then copy or blur 128-bit HDR surfaces several times.

The highest-value path is:

1. Consolidate opaque/cutout camera-space outputs into a feature-driven G-buffer.
2. Replace per-light geometry replay with bounded screen-space lighting from that G-buffer.
3. Enable the existing object batching design on GLSL 1.50/4.00 through a UBO fallback.
4. Replace full-resolution repeated blur chains with scaled pyramids.
5. Make surface ownership explicitly ping-pong instead of copying results back.
6. First apply independent low-risk fixes: correct the depth/normal condition, eliminate duplicate DoF work, reuse depth, cache fixed data, replace generated grain with blue noise, and skip stages that a requested render pass does not consume.

The first two items remove costs proportional to scene draw count. The others mainly reduce submission overhead, shaded pixels, memory bandwidth, and target transitions.

## Current cost structure

The top-level sequence is in `Generated/Scripts48.cpp:276-358`:

1. Update temporal jitter.
2. Render base buffers.
3. Render shadows and direct lights.
4. Render indirect lighting and SSAO.
5. Combine the scene.
6. Render reflections and tone mapping.
7. Render fog.
8. Render scene effects such as DoF and glow.
9. Accumulate and unpack progressive samples.
10. Run bloom, lens dirt, chromatic aberration, distortion, color correction, grain, vignette, and overlays.

### Repeated camera-space scene draws

One high-quality sample traverses `global::render_list` through `render_world()` for the following operations:

| Operation | Traversals | Evidence |
|---|---:|---|
| Diffuse/color | 1 | `Generated/Scripts49.cpp:56-77` |
| Depth + normal | 1 | `Generated/Scripts49.cpp:78-91` |
| Material + emissive | 1 | `Generated/Scripts49.cpp:92-100` |
| Glint | 1 | `Generated/Scripts49.cpp:281-292` |
| Scene/light mask | 1 | `Generated/Scripts49.cpp:302-313` |
| Sun lighting | 1 | `Generated/Scripts49.cpp:412-420` |
| Each shadowed point light, lighting | 1 | `Generated/Scripts49.cpp:498-509` |
| Each spot light, lighting | 1 | `Generated/Scripts49.cpp:534-545` |
| Each batch of up to 31 shadowless points | 1 | `Generated/Scripts49.cpp:582-614` |
| AO mask | 1 | `Generated/Scripts49.cpp:640-652` |
| Subsurface data | 1 | `Generated/Scripts49.cpp:699-707` |
| DoF depth | 1 | `Generated/Scripts48.cpp:640-649` |
| Fog | 1 | `Generated/Scripts48.cpp:731-738` |
| Transparent-background alpha fix | up to 2 | `Generated/Scripts49.cpp:69-73`, `Generated/Scripts48.cpp:767-771` |
| Glow source | 1 per glow/falloff flavor | `Generated/Scripts48.cpp:802-813`, called at `Generated/Scripts49.cpp:855-860` |

`render_world()` selects a shader and walks the full ordered render list (`Generated/Scripts50.cpp:751-790`). Each repetition multiplies CPU traversal, uniform setup, texture and state changes, vertex processing, alpha testing, wind deformation, and GPU draw calls.

Shadow generation adds:

- `C` traversals for `C` sun cascades (`Generated/Scripts49.cpp:395-408`); the sun shader currently assumes three cascades (`Asset/Shaders/shader_high_light_sun.vsh:4-5`).
- Six traversals per shadowed point light (`Generated/Scripts49.cpp:468-494`).
- One traversal per spot-light shadow (`Generated/Scripts49.cpp:519-530`).

Ignoring optional alpha-fix passes, the approximate traversal count per sample is:

```text
5 base
+ (sun enabled ? cascades + 1 : 0)
+ 7 * shadowedPointLights
+ 2 * spotLights
+ ceil(shadowlessPointLights / 31)
+ (SSAO ? 1 : 0)
+ (subsurface ? 1 : 0)
+ (DoF ? 1 : 0)
+ (fog ? 1 : 0)
+ enabledGlowVariants
```

The five base traversals are color, depth/normal, material/emissive, glint, and scene mask. This draw multiplication is the primary scalability problem in effect-heavy scenes.

### Full-screen passes and copies

- DoF uses one CoC pass, 32 CoC blur draws, and one expensive bokeh draw (`Generated/Scripts48.cpp:652-720`).
- Glow uses six full-size blur draws plus a composite per normal/falloff invocation (`Generated/Scripts48.cpp:817-874`).
- Lens dirt uses another six full-size blur draws, a mask multiply, and a composite (`Generated/Scripts48.cpp:999-1061`).
- Bloom runs threshold, blur, copy, and composite passes; the directional route repeats three blur passes per aperture blade (`Generated/Scripts48.cpp:361-570`).
- Reflection application composites to an intermediate and copies back (`Generated/Scripts49.cpp:175-197`).
- Tone mapping first copies the source, then draws back into the original target (`Generated/Scripts49.cpp:737-764`).
- Fog copies the base around its apply pass (`Generated/Scripts48.cpp:739-775`).
- `render_post()` starts by copying input even when a phase has no enabled effect (`Generated/Scripts49.cpp:112-134`, `Generated/Scripts49.cpp:849-885`).
- Sample accumulation copies two or three old accumulation surfaces before one MRT update (`Generated/Scripts49.cpp:202-252`).

Most targets are full resolution. All HDR targets use 128-bit `RGBA32F` (`Render/FrameBuffer.cpp:38-51`, `Render/FrameBuffer.cpp:195-198`), amplifying the bandwidth cost of copies and blur chains.

## P0: independent, low-risk improvements

### 1. Correct the depth/normal enable condition

At `Generated/Scripts50.cpp:82`, `global::render_depth_normals` includes:

```cpp
global::_app->project_render_subsurface_samples >= 0
```

Zero is treated as disabled before subsurface rendering (`Generated/Scripts49.cpp:568-569`), so this term appears to keep depth/normal generation permanently enabled. Change it to `> 0`, then explicitly include every real consumer: SSAO, indirect lighting, reflections, enabled subsurface, DoF after depth reuse, and requested depth/normal/AO render-pass output.

This can remove one complete scene traversal when no depth-dependent feature or output is active. Confirm only that negative values are not a hidden sentinel; inspected consumers use positive enable checks.

### 2. Remove the duplicate DoF CoC draw

The CoC target is drawn twice with the same shader at `Generated/Scripts48.cpp:662-663`: once with `draw_blank()`, then with `draw_surface_exists(prevsurf)`. `Asset/Shaders/shader_high_dof_coc.fsh:1-36` samples `uDepthBuffer`, not `gm_BaseTexture`, so the draws produce the same full-screen result. Retain one draw.

### 3. Reuse the existing high-quality depth for DoF

DoF redraws the complete scene into another depth surface (`Generated/Scripts48.cpp:637-649`), although `render_high_passes()` already creates packed linear depth (`Generated/Scripts49.cpp:46-50`, `Generated/Scripts49.cpp:78-90`). Both use the same three-channel packing (`Asset/Shaders/shader_depth.fsh:11-14`, `Asset/Shaders/shader_high_depth_normal.fsh:15-18`).

The encoded ranges differ: the high-quality surface uses `global::depth_near/depth_far`, while DoF currently submits `cam_near/cam_far` (`Generated/Scripts55.cpp:742-751`). Decode with the source surface's range. This removes one scene traversal per DoF sample.

### 4. Cache data reconstructed in hot paths

- The SSAO kernel is created at startup (`Generated/Scripts50.cpp:243`) and regenerated every SSAO pass (`Generated/Scripts49.cpp:637-640`). Rebuild only when its relevant settings change.
- DoF sample arrays are rebuilt during final-shader setup (`Generated/Scripts55.cpp:753-769`). Cache by blade count, blade angle, and blur ratio.
- Projection and view inverses are independently recomputed for ray tracing, SSAO, and subsurface (`Generated/Scripts55.cpp:929-931`, `:971-972`, `:994-995`). Cache once per camera-matrix change.

These reduce CPU time rather than draw count, but are cheap improvements for submission-bound scenes.

### 5. Replace point-by-point grain generation

`render_high_grain()` invokes `render_generate_noise()` (`Generated/Scripts48.cpp:905-925`). The generator loops over the texture on the CPU and submits one point for every texel (`Generated/Scripts48.cpp:13-40`). At 3840x2160, its 480x480 texture means more than 230,000 point submissions per update.

Use `spr_blue_noise` or the cached sample-noise texture, varied by a frame-dependent UV offset, rotation/reflection, or channel permutation. `uTime` exists but is unused in `Asset/Shaders/shader_noise.fsh:3-10`. This needs only ordinary texture sampling and works on every target backend.

### 6. Add render-pass dependency masks

For auxiliary render-pass output, `render_high()` still performs unrelated scene composition, reflection/tonemap, fog, scene effects, accumulation, and unpacking before selecting `global::render_pass_surf` (`Generated/Scripts48.cpp:292-331`). The combined `finalsurf` is ignored when `global::render_pass > 0` (`Generated/Scripts48.cpp:316-325`).

Compute dependencies from the selected output and early-out unrelated work. For example:

- Diffuse needs color, not lighting, combined composition, tonemapping, fog, or post.
- Material needs material output, not scene color or lighting.
- Depth and normal need only the shared depth-normal output.
- AO needs depth, normal, relevant masks/emissive, and SSAO, but not direct lighting or post.
- Shadow, specular, indirect, and reflection passes should enable only their actual prerequisites.

This is especially valuable for multi-pass exports and naturally drives optional G-buffer attachment selection.

## P1: consolidate camera geometry into a feature-driven G-buffer

The color, depth/normal, material/emissive, and mask passes repeat wind deformation, transformations, alpha/hash testing, normal decoding, and material decoding. Examples include `shader_high_depth_normal` (`Asset/Shaders/shader_high_depth_normal.vsh:115-146`, `.fsh:45-60`), `shader_high_material` (`Asset/Shaders/shader_high_material.vsh:61-82`, `.fsh:97-129`), and the repeated material work in subsurface output (`Asset/Shaders/shader_high_subsurface.fsh:35-98`).

For opaque and alpha-tested geometry, emit needed results in one feature-driven pass:

| Attachment | Suggested contents | Suggested format |
|---|---|---|
| Scene color | Linear diffuse/color and alpha | `RGBA8`, or `RGBA16F` where range requires it |
| Depth | Linear camera depth | `R32F` |
| Normal | Octahedral normal | `RG16F`, with tested `RGB10_A2` option |
| Material/effects | Roughness, metallic/F0, emissive, compact flags/masks | `RGBA8` or `RGBA16F` |
| Optional effect data | Glow/glint/SSS values that do not fit above | Enabled only when consumed |

This relies only on MRT and ordinary fragment outputs. The existing shader converters already handle MRT for D3D11 and OpenGL (`Asset/ShaderLoadD3D11.cpp:130-149`, `Asset/ShaderLoadOpenGL.cpp:38-60`), and the runtime binds MRTs at `Gml/RenderFunc.cpp:467-475`.

Implementation constraints:

- Split opaque/cutout and translucent queues. Consolidate opaque/cutout first; retain a smaller ordered forward path for transparency whose blending cannot safely write packed attributes.
- Select a narrow attachment profile from active features. A maximum-width G-buffer can regress bandwidth-limited low-end hardware.
- Perform texture alpha/hash evaluation once per fragment and write all outputs only after that decision.
- Encode object participation in compact flags or channels so AO, fog, glint, glow, SSS, and scene masking keep current semantics.
- Share one hardware depth attachment. Current D3D MRT binding already takes the first framebuffer's DSV (`Render/GraphicsApiHandler.cpp:181-199`).

Expected result: five base camera traversals approach one opaque/cutout traversal plus a translucent fallback. AO, fog, SSS, glint, and glow source replays can then be removed as their data moves into shared attachments.

## P1: move direct lighting to screen space

Each shadowed point or spot light currently redraws visible geometry and then performs two full-screen additive applications (`Generated/Scripts49.cpp:500-562`). Sun lighting has the same pattern (`Generated/Scripts49.cpp:412-434`). Shadowless points are grouped in batches of 31, but every batch still redraws the scene (`Generated/Scripts49.cpp:574-635`).

After establishing depth, normal, material, and masks:

- Reconstruct view/world position as the existing SSAO and ray shaders do (`Asset/Shaders/shader_high_ssao.fsh:39-50`, `Asset/Shaders/shader_high_raytrace.fsh:199-216`).
- Evaluate sun, point, and spot BRDFs in screen space using the existing shadow maps.
- Preserve GLSL-1.50 uniform-array batches for shadowless lights rather than requiring SSBOs.
- Bound point/spot work with CPU-computed screen rectangles or simple light-volume geometry. A full-screen loop over many lights can be worse on low-end GPUs.

Write diffuse and specular accumulations directly through additive MRT blending, eliminating a temporary clear and two apply draws per light. OpenGL applies the current blend state to all draw buffers, but D3D only initializes `RenderTarget[0]` (`Render/GraphicsApiHandler.cpp:301-317`). Extend D3D blend-state setup to every active output, or add explicit per-target blend states.

Use a hybrid path: deferred lighting for opaque/cutout surfaces and a single ordered forward phase for transparent/layered content. Keep the present per-object route as a correctness fallback during migration.

## P1: enable object batching in GLSL 1.50/4.00

`VertexBufferRenderer` already combines consecutive vertex buffers and puts an object index into the high 16 bits of `Vertex::data` (`Render/VertexBufferRenderer.cpp:15-40`, `:154-180`; `Render/Vertex.cpp:144-148`). D3D uses a constant-buffer object array. OpenGL uses an SSBO and explicitly disables batching below GL 4.3 (`Asset/ShaderLoadOpenGL.cpp:11-16`); then `Shader::SubmitObject()` flushes each time (`Asset/Shader.cpp:568-586`).

Add a UBO fallback:

- Emit a GLSL 1.50-compatible `std140` uniform block for per-object values.
- Query `GL_MAX_UNIFORM_BLOCK_SIZE` and calculate a per-shader object limit.
- Bind with `glUniformBlockBinding`, without GLSL 4.20 binding qualifiers.
- Retain the existing flat object index from vertex to fragment stage.
- Keep SSBOs on GL 4.3 and the current D3D constant-buffer path.
- Generate explicit CPU and shader layouts with correct `std140` padding, especially for matrices and `vec3` values.
- Split batches when uniform-block capacity is reached; correctness must not depend on a large block.

Sort only opaque submissions by shader, static texture, and material state. `SubmitTexture()` flushes when a sampler changes (`Asset/Shader.hpp:68-72`), so sorting substantially enlarges batches. Preserve depth order for translucent geometry.

This is the most important draw-call improvement specifically for GL 4.0/GLSL 1.50 cards and does not require a vertex-format change.

## P1: render point-shadow faces directly into their atlas

Each point-light face is rendered into a scratch surface and copied into a 3x2 atlas (`Generated/Scripts49.cpp:459-494`), adding six copy draws and multiple target transitions per light.

Add viewport/scissor control to the surface target API:

1. Bind the atlas once.
2. Set the viewport and scissor to a tile.
3. Clear that tile and render the corresponding direction.
4. Repeat for six tiles, then restore the viewport.

D3D11 viewports and OpenGL `glViewport`/`glScissor` exist at all target levels. Keeping the 2D atlas preserves current sampling and avoids cube-array requirements. Filtering must remain inside tile boundaries. This removes the six copy draws; it does not remove the six caster traversals.

## P1: replace copy-back chains with ping-pong ownership

Effect functions should return the surface holding their output, allowing logical surface IDs or handles to swap:

- Tone map into an alternate target and return it, removing the pre-copy at `Generated/Scripts49.cpp:742-747`.
- Return the already-composited `render_surface_hdr[2]` from reflection application instead of copying back (`Generated/Scripts49.cpp:175-197`).
- Apply fog from base + mask into an alternate target and return it, removing copies around `Generated/Scripts48.cpp:739-775`. The operation is a simple mask/color application (`Asset/Shaders/shader_high_fog_apply.fsh:1-10`) and could later be fused with tonemapping if ordering remains correct.
- If a scene or post phase has no active effect, immediately return `prevsurf`; otherwise let its first effect select the alternate target instead of making the unconditional copy at `Generated/Scripts49.cpp:112-134`.
- Keep two sets of exponent/decimal/alpha accumulation surfaces, read A and write B in the MRT update, then swap. This removes the two or three copies at `Generated/Scripts49.cpp:226-232`.

Double-buffered accumulation costs memory. At high resolutions on constrained cards, choose between it and the copy path using a memory budget, or investigate whether one supported higher-precision accumulation target gives equivalent accuracy with lower total cost.

## P1: remove clears before guaranteed overwrite

Many post targets are cleared and immediately covered. Add an explicit replace state (`src=one`, `dst=zero`) and omit the clear when a full-screen shader covers every pixel and cannot discard. Current `bm_normal` is source-alpha blending (`Gml/RenderFunc.cpp:78-86`), so clear removal must accompany the new state.

Candidates include chromatic aberration, distortion, color correction, grain, vignette, tonemapping, ray resolve, and copies. Keep clears for partial, discarded, scissored, or additive passes.

## P2: replace repeated full-resolution blur with pyramids

### DoF CoC dilation

`shader_high_dof_coc_blur.fsh` samples four texels on each side and is run horizontally and vertically 16 times (`Asset/Shaders/shader_high_dof_coc_blur.fsh:1-47`, `Generated/Scripts48.cpp:669-698`). Replace 32 full-resolution passes with:

1. One CoC generation.
2. Conservative downsampling, using front-CoC maximum and appropriate back-CoC aggregation.
3. Controlled upsample/dilation through four or five levels.
4. The existing or revised bokeh resolve.

This uses only regular textures and GLSL-1.50-compatible operations. Retain the old path temporarily as a visual reference for near/far edge behavior.

### Bloom, glow, and lens dirt

`Asset/Shaders/shader_blur.fsh:1-48` supports as many as 65 samples, while glow and lens dirt run several horizontal/vertical radius passes at full resolution. Use half-, quarter-, and eighth-resolution levels and composite weighted results.

Share the pyramid implementation and transient surface pool. Share actual pyramid contents only where source and threshold semantics are identical; bloom threshold, object glow, and lens accumulation normally are not. Provide low, medium, and high profiles by varying source scale, levels, taps, and depth-aware upsampling.

## P2: use genuine reduced-resolution SSAO, indirect light, and reflections

Ray tracing presently shades a full-size target but skips alternating pixels (`Asset/Shaders/shader_high_raytrace.fsh:258-297`), followed by a full-size resolve (`Asset/Shaders/shader_high_raytrace_resolve.fsh:40-64`). Allocate a true half-resolution target, shade every pixel there with jitter, and bilateral-upsample using full-resolution depth and normal.

SSAO takes 12 depth/normal samples per full-resolution pixel (`Asset/Shaders/shader_high_ssao.fsh:64-126`). A half-resolution target plus bilateral upsample is a strong low/mid-tier mode; retain full resolution as a quality option. Subsurface intermediates can be scaled later after more sensitive edge testing.

## P2: fuse compatible pointwise post effects

Chromatic aberration, distortion, color correction, grain, vignette, and camera color are separate full-screen passes (`Generated/Scripts49.cpp:849-885`). A combined variant can preserve order:

1. Compose distortion into the sampling coordinate.
2. Sample chromatic aberration from that coordinate.
3. Apply color correction.
4. Add blue-noise grain.
5. Apply vignette and camera color transforms.

Draw watermark geometry afterward. Compile variants for common feature sets so low-end cards do not pay for disabled branches. The current CA shader can take roughly 97 source samples per pixel (32 iterations across RGB plus alpha; `Asset/Shaders/shader_ca.fsh:15-60`), so add a sample-count quality setting and a zero-blur fast path; reducing its loop may matter more than saving its draw call.

## P2: add descriptor-aware surfaces and cheaper formats

`FrameBuffer` currently exposes only `RGBA8` and `RGBA32F` (`Render/FrameBuffer.cpp:38-51`, `:195-198`). D24S8 is allocated whenever `depthBuffer` is true, while `surface_require()` defaults depth to true (`Generated/Scripts.hpp:7725`, `Generated/Scripts58.cpp:84-104`). Many post targets therefore carry unused depth/stencil.

Add explicit surface descriptors containing dimensions, color format, depth/stencil requirement, usage, and optionally transient lifetime. Then:

- Prefer `RGBA16F` for HDR intermediates unless measured range/precision requires 32-bit channels.
- Use `R32F` sampled linear depth instead of RGB-packed depth.
- Use octahedral `RG16F` normals, or tested `RGB10_A2` on tighter profiles. The current normal target is `RGBA32F` and scales values by eight (`Generated/Scripts.hpp:158`, `Asset/Shaders/shader_high_depth_normal.fsh:20-23`).
- Use `R8` for masks and CoC where testing accepts its precision.
- Allocate depth/stencil only for geometry targets that use it.
- Recreate a surface whenever any descriptor field changes. Current `surface_require()` checks existence and dimensions, not `depth` or `hdr` (`Generated/Scripts58.cpp:84-104`).

Compatible mappings exist on both APIs: D3D `R16G16B16A16_FLOAT` / OpenGL `RGBA16F`, D3D `R32_FLOAT` / OpenGL `R32F`, and D3D `R8_UNORM` / OpenGL `R8`. Keep current formats as capability or correctness fallbacks. Pay special attention to progressive HDR accumulation, emissive range, normals, and transparent edges.

## P2: reduce state and binding overhead

The renderer performs avoidable per-draw work:

- `shader_set()` submits, releases, binds, clears state, and resubmits matrices even if the requested shader is active (`Gml/RenderFunc.cpp:335-348`).
- OpenGL binds every active texture and calls `glTexParameteri` on every draw; a `changed` flag is cleared but does not skip that work (`Asset/Shader.cpp:632-674`).
- D3D unbinds every sampler and SRV after every draw (`Asset/Shader.cpp:720-727`) and uploads buffers wholesale (`Asset/Shader.cpp:690-704`).
- Target reset repeatedly returns to the window between offscreen passes (`Gml/RenderFunc.cpp:437-495`).
- OpenGL `SetMRTIndex()` repeatedly allocates an attachment array (`Render/GraphicsApiHandler.cpp:497-514`).

Recommended changes:

- Make same-shader binds a no-op unless a real reset is required.
- Retain texture and sampler bindings and update dirty slots only.
- On D3D, unbind only SRVs that alias a target about to be written.
- Upload dirty buffer ranges or use a backend-appropriate dynamic/ring buffer.
- Keep the high-quality render graph offscreen across dependent passes.
- Cache MRT attachment sets and their storage.

These optimizations work on every requested backend and complement draw consolidation.

## P3: shadow reuse and shared culling

Cache a shadow map only when its light/camera state and all caster transforms, visibility, alpha/material state, wind state, and shadow settings remain stable. Soft-shadow sampling intentionally jitters sun/light positions after early samples (`Generated/Scripts49.cpp:378-387`, `Generated/Scripts49.cpp:442-451`), so unconditional cache reuse changes output.

Begin with hard opaque shadows: zero light size/sun angle, no wind-animated caster, unchanged scene/light transforms, and no sample-dependent alpha hash. Use broad invalidation first, then refine.

Separately, build a pass-independent visible/caster packet list once per sample. `render_world()` currently walks the ordered list for every mode. Reusing culled packets and resolved per-object/material data cuts CPU work even before geometry passes are merged.

## Cross-backend compatibility

| Proposal | D3D11 / FL10 | OpenGL 4.3 | OpenGL 4.0 / GLSL 1.50 | Low-end behavior |
|---|---|---|---|---|
| MRT G-buffer | Supported | Supported | Supported | Narrow attachment profile |
| Deferred bounded lights | Supported | Supported | Supported | Scissors/volumes and small light batches |
| Additive MRT | Extend state to all RTs | Supported | Supported | Same shader path |
| Object batching | Existing cbuffer basis | SSBO or UBO | UBO fallback | Batch size from block limit |
| Direct point-shadow atlas | Viewport/scissor | Viewport/scissor | Viewport/scissor | Removes copies |
| Ping-pong surfaces | Supported | Supported | Supported | Memory-budget fallback |
| Blur/downsample pyramids | Supported | Supported | Supported | Fewer levels/taps |
| Half-resolution SSAO/rays | Supported | Supported | Supported | Primary low/mid quality mode |
| Fused post variants | Supported | Supported | Supported | Lower CA samples |
| `RGBA16F`, `R32F`, `RG16F`, `R8` | Supported mappings | Supported | Supported | Capability-tested fallback |

No baseline proposal requires compute, SSBOs, image load/store, texture arrays, bindless textures, or indirect draw commands.

## Recommended implementation sequence

### Phase 1: measurement and independent fixes

1. Add per-stage counters for scene traversals, GPU draws, primitives, target changes, pixels processed, and bytes copied.
2. Add backend GPU timestamps where supported and CPU timers as fallback.
3. Fix the depth/normal condition.
4. Remove duplicate CoC rendering and reuse the high-depth target for DoF.
5. Cache kernels, DoF samples, and inverse matrices.
6. Replace dynamic grain generation with blue noise.
7. Make empty post phases no-ops.
8. Add render-pass dependency masks and early-outs.

### Phase 2: eliminate bandwidth-only work

1. Add replace blending and remove proven-redundant clears.
2. Ping-pong tone map, reflections, fog, post effects, and sample accumulation.
3. Render point-shadow faces directly into atlas viewports.
4. Add descriptor-aware transient surfaces and omit unused depth attachments.

### Phase 3: remove scene-draw multiplication

1. Add the GLSL-1.50 UBO batching fallback and opaque state sorting.
2. Build the minimal opaque/cutout G-buffer.
3. Reuse its depth for every screen-space consumer.
4. Pack feature masks and remove AO/fog/SSS/glint/glow replays incrementally.
5. Move direct light evaluation to bounded screen-space passes and accumulate with MRT.
6. Preserve and separately optimize the ordered transparent forward path.

### Phase 4: scale layered effects

1. Replace DoF CoC dilation with a pyramid.
2. Move bloom, glow, and lens dirt to scaled pyramids.
3. Allocate true half-resolution SSAO and ray targets with bilateral upsample.
4. Fuse compatible post effects and introduce quality variants.
5. Evaluate conditional shadow caching after correctness and timing instrumentation exists.

## Validation requirements

Validate across:

- D3D11 feature levels 11 and 10 where available.
- OpenGL shader modes 430, 400, and 150.
- Integrated/low-end, mid-range, and high-end cards.
- Opaque-heavy, alpha-cutout-heavy, translucent/layered, many-light, many-shadow, and maximum-effect scenes.
- Transparent and solid backgrounds.
- Single-sample and progressive multi-sample rendering.
- Diffuse, material, depth, normal, AO, shadow, specular, indirect, and reflection output passes as well as combined output.

Track scene traversals, draw calls, target changes, full-screen pixels shaded, copied bytes, render-target memory, CPU submission time, and GPU time by stage. Compare output around opaque and alpha-hashed edges, normal-mapped surfaces, fog boundaries, DoF transitions, glow/bloom radii, transparency ordering, and progressive convergence.

## Priority by bottleneck

| Bottleneck | Highest-value changes |
|---|---|
| CPU/draw-call limited | GLSL 1.50 UBO batching, opaque sorting, G-buffer consolidation, deferred lighting |
| Vertex limited | G-buffer consolidation, deferred lighting, caster culling/cache |
| Bandwidth limited | Ping-pong ownership, fewer copies/clears, scaled pyramids, cheaper formats, no unused depth |
| Fragment limited | Reduced-resolution SSAO/rays, bounded lights, lower CA samples, blur pyramids |
| Many shadowed point lights | Direct atlas rendering, caster culling, deferred light application, conditional cache |
| Many layered effects | Fused post, transient pyramids, blue-noise grain, empty-stage skipping |

## Bottom line

The central problem is architectural rather than one unusually slow shader: `render_high()` redraws the same scene for many outputs and lights, then repeatedly moves full-resolution images between expensive surfaces. The strongest backend-compatible target is a hybrid deferred pipeline: a feature-sized G-buffer for opaque/cutout geometry, bounded screen-space lighting, an ordered forward fallback for transparency, and a render graph that swaps transient targets instead of copying results back.

The existing MRT conversion and binding, packed per-object index, D3D object buffers, and 31-light uniform batching already provide much of the foundation. Extending them with GLSL-1.50 UBO batching and conventional fragment/texture techniques produces broad benefits on low-to-high-end cards without making GL 4.3-only functionality a requirement. All referenced `Generated` implementations are first-class edit locations for this work.
