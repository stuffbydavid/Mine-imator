Prompt:

*Investigate performance optimizations and opportunities for reducing repeated draw calls, limiting the scope to changes in CppProject only. The focus should be on improving the rendering speed of 3D scenes with many layered effects in render_high(). New proposed shader functionality or format changes should be compatible with both D3D11 and OpenGL 4.3-4.0/GLSL 1.50 modes, and on low-to-high end cards.*

# Rendering performance analysis

## Scope and method

This analysis is limited to source and shader files under `CppProject`. No external project, documentation, benchmark, build, or application run was used. Findings are based on static inspection of the generated high-quality render pipeline, the hand-written C++ renderer, the D3D11/OpenGL backends, and the shaders bundled in `CppProject`.

The requested compatibility floor is treated as:

- D3D11, including the feature-level 10 fallback requested by `GraphicsApiHandler`.
- OpenGL using the existing GLSL `150 core`, GLSL 4.00, and GLSL 4.30 modes.
- Low-to-high-end GPUs, so compute shaders, image load/store, SSBO-only solutions, bindless resources, and GPU-driven indirect rendering are not required by the primary recommendations.

The generated render files explicitly warn that edits can be overwritten (`Generated/Scripts48.cpp:1-6`, `Generated/Scripts49.cpp:1-6`). The findings identify those call sites because they are the active implementation, but durable implementation should put reusable mechanisms in the hand-written `Render`, `Asset`, and `Gml` layers and keep generated-code changes as small as possible.

## Executive summary

`render_high()` is dominated by repeated scene traversal and full-resolution surface traffic. A scene is redrawn for color, depth/normal, material/emissive, glint, scene mask, every light, AO mask, subsurface data, fog, DoF depth, and each glow flavor. Shadowed point lights add six more scene traversals per light for the six shadow directions. Between those traversals, many effects repeatedly copy or clear full-size textures.

The best improvement path is:

1. **Consolidate camera-space geometry passes into a feature-driven G-buffer.** For opaque/cutout geometry, produce color, depth/normal, material/emissive, and compact effect masks in one traversal. Keep a compatibility/fallback path for translucent content where MRT blending cannot preserve current ordering.
2. **Replace per-light scene redraws with deferred screen-space lighting from that G-buffer.** Accumulate shadow and specular outputs directly with additive MRT blending, removing both the geometry replay and two copy/add draws per light.
3. **Make the current batching mechanism work in GLSL 1.50/4.00 using a uniform-buffer fallback.** At present, OpenGL batching is forcibly disabled below GL 4.3 even though the vertex format already carries a per-object index.
4. **Replace full-resolution repeated blur chains with resolution-scaled pyramids.** DoF currently executes 32 CoC dilation draws; glow and lens dirt use six full-size separable blur draws each; bloom can do even more per aperture blade.
5. **Turn the surface chain into explicit ping-pong ownership rather than copy-back operations.** Reflections, tone mapping, fog, post startup, and sample accumulation all contain avoidable full-screen copies.
6. **Apply the low-risk fixes first.** Correct the always-true depth/normal condition, remove the duplicate DoF CoC draw, reuse the existing depth buffer for DoF, cache SSAO/DoF data, and replace CPU-generated grain with the already bundled blue-noise texture.

The first two changes attack the multiplicative cost: today, if a normal camera scene traversal takes `B` GPU draw calls, enabling effects and lights repeats approximately `B` each time. The later changes mostly remove constant full-screen draws and bandwidth.

## What `render_high()` currently does

The top-level order is visible at `Generated/Scripts48.cpp:276-358`:

1. Update temporal jitter.
2. Render base buffers.
3. Render shadows/direct lights.
4. Render indirect lighting and SSAO.
5. Render the combined scene.
6. Render reflections and tone mapping.
7. Render fog.
8. Render scene effects such as DoF and glow.
9. Copy the sample into an accumulation target, add it to encoded accumulation textures, and unpack accumulated samples.
10. Run post effects such as bloom, lens dirt, chromatic aberration, distortion, color correction, grain, vignette, and overlay.

### Camera-space geometry replay count

One high-quality sample traverses the complete `global::render_list` through `render_world()` for all of the following:

| Operation | Scene traversals | Evidence |
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
| Alpha fix for transparent background | up to 2 | `Generated/Scripts49.cpp:69-73`, `Generated/Scripts48.cpp:767-771` |
| Glow source | 1 per glow/falloff flavor | `Generated/Scripts48.cpp:802-813`; invoked up to twice at `Generated/Scripts49.cpp:855-860` |

`render_world()` selects a shader and iterates the full ordered render list (`Generated/Scripts50.cpp:751-790`). Consequently, every row above multiplies CPU object traversal, uniform work, texture/state changes, vertex processing, alpha tests, wind deformation, and GPU draw calls.

There are additional shadow-caster traversals:

- `C` scene traversals for `C` sun cascades (`Generated/Scripts49.cpp:395-408`). The sun shader is hard-coded around three cascades (`Asset/Shaders/shader_high_light_sun.vsh:4-5`).
- Six scene traversals for every shadowed point light (`Generated/Scripts49.cpp:468-494`).
- One shadow traversal for every spot light (`Generated/Scripts49.cpp:519-530`).

Ignoring optional alpha-fix passes, the approximate camera/light traversal count per sample is therefore:

```text
5 base traversals
+ (sun enabled ? C + 1 : 0)
+ 7 * shadowedPointLights
+ 2 * spotLights
+ ceil(shadowlessPointLights / 31)
+ (SSAO ? 1 : 0)
+ (subsurface ? 1 : 0)
+ (DoF ? 1 : 0)
+ (fog ? 1 : 0)
+ enabledGlowVariants
```

The five base traversals are color, depth/normal, material/emissive, glint, and scene mask. This is the main reason layered scenes scale poorly.

### Full-screen and copy traffic

The pipeline also performs many full-size passes:

- DoF executes one CoC pass, **32** CoC blur draws (16 horizontal/vertical iterations), and one expensive bokeh draw (`Generated/Scripts48.cpp:652-720`).
- Glow performs six full-size blur draws plus a composite for each normal/falloff invocation (`Generated/Scripts48.cpp:817-874`).
- Lens dirt performs another six full-size blur draws, a mask multiply, and a composite (`Generated/Scripts48.cpp:999-1061`).
- Bloom performs a threshold pass and multiple blur/copy/composite passes, with the directional path repeating three blur passes per aperture blade (`Generated/Scripts48.cpp:361-570`).
- Reflection application uses an intermediate composite and then copies it back (`Generated/Scripts49.cpp:175-197`).
- Tone mapping copies the source before drawing it back into the original target (`Generated/Scripts49.cpp:737-764`).
- Fog copies the base twice around its apply pass (`Generated/Scripts48.cpp:739-775`).
- Each call to `render_post()` begins by copying its input even if that phase contains no enabled effect (`Generated/Scripts49.cpp:112-134`, `Generated/Scripts49.cpp:849-885`). `render_high()` calls scene and post phases separately.
- Sample accumulation copies two or three prior accumulation surfaces before one MRT update (`Generated/Scripts49.cpp:202-252`).

Most of these surfaces are full resolution, and all HDR surfaces use 128-bit `RGBA32F` (`Render/FrameBuffer.cpp:38-51`, `Render/FrameBuffer.cpp:195-198`). This makes unnecessary copies unusually expensive.

## Prioritized findings

### P0 — Quick, low-risk corrections

#### 1. Correct the depth/normal enable condition

`global::render_depth_normals` includes:

```cpp
global::_app->project_render_subsurface_samples >= 0
```

at `Generated/Scripts50.cpp:82`. Since zero is also the disabled condition used before subsurface scattering (`Generated/Scripts49.cpp:568-569`), this term appears to make depth/normal generation permanently enabled.

Change the subsurface term to `> 0`, then explicitly include every consumer that needs the buffer: DoF if it is changed to reuse depth, and requested depth/normal/AO render-pass outputs even when the corresponding combined-render feature is disabled. This can eliminate an entire scene traversal in configurations without SSAO, indirect light, reflections, subsurface scattering, or DoF.

Risk: low, but confirm negative values are not a hidden sentinel. All inspected consuming code uses positive enable checks.

#### 2. Remove the duplicate DoF CoC draw

The CoC target is drawn twice with the same shader at `Generated/Scripts48.cpp:662-663`: first with `draw_blank()`, then with `draw_surface_exists(prevsurf)`. `shader_high_dof_coc.fsh` only samples `uDepthBuffer` and never samples `gm_BaseTexture` (`Asset/Shaders/shader_high_dof_coc.fsh:1-36`), so both draws produce the same full-screen result. Keep one full-screen primitive.

Expected result: one full-resolution draw removed whenever DoF is enabled.

#### 3. Reuse the high-quality depth surface for DoF

DoF redraws all geometry into a separate depth surface (`Generated/Scripts48.cpp:637-649`), despite `render_high_passes()` already producing packed linear depth (`Generated/Scripts49.cpp:46-50`, `Generated/Scripts49.cpp:78-90`). Both formats use the same three-channel packing (`Asset/Shaders/shader_depth.fsh:11-14`, `Asset/Shaders/shader_high_depth_normal.fsh:15-18`).

The ranges differ: the high-quality depth buffer uses `global::depth_near/depth_far`, while DoF currently submits `cam_near/cam_far` (`Generated/Scripts55.cpp:742-751`). Make the CoC shader decode with the source buffer's range. This removes one complete scene traversal per sample when DoF is enabled.

#### 4. Stop regenerating fixed/random data in hot paths

- The SSAO kernel is created at startup (`Generated/Scripts50.cpp:243`) and then regenerated every SSAO pass (`Generated/Scripts49.cpp:637-640`). Reuse it until sample count/settings change.
- DoF sample arrays are rebuilt during shader setup every final DoF draw (`Generated/Scripts55.cpp:753-769`). Cache by blade count, blade angle, and blur ratio.
- Projection and view inverses are recomputed independently by ray tracing, SSAO, and subsurface setup (`Generated/Scripts55.cpp:929-931`, `Generated/Scripts55.cpp:971-972`, `Generated/Scripts55.cpp:994-995`). Cache them once when the camera matrices change.

These are CPU improvements rather than draw-call reductions, but they are simple and help scenes already CPU-bound by many draw submissions.

#### 5. Replace per-frame point-by-point grain generation

`render_high_grain()` calls `render_generate_noise()` every time (`Generated/Scripts48.cpp:905-925`). That generator runs nested CPU loops and submits one point per texel (`Generated/Scripts48.cpp:13-40`). At a 3840×2160 output, its chosen noise dimension is 480×480, or more than 230,000 point submissions per update.

Use `spr_blue_noise` or the existing cached sample-noise texture with a frame-dependent UV offset, rotation/reflection choice, or channel permutation in `shader_noise.fsh`. `uTime` already exists in that shader but is currently unused (`Asset/Shaders/shader_noise.fsh:3-10`). This is compatible with every existing backend and removes both CPU work and a dynamic surface render.

#### 6. Build a render-pass dependency mask and skip unused stages

Even when an auxiliary render pass is requested, the top-level function continues through `render_high_scene()`, reflection/tonemap logic, fog, scene post processing, sample accumulation, and unpacking before finally choosing `global::render_pass_surf` (`Generated/Scripts48.cpp:292-331`). The combined `finalsurf` is ignored by the output selection when `global::render_pass > 0` (`Generated/Scripts48.cpp:316-325`).

Compute required buffers/stages from the selected pass and early-out unrelated work. Examples:

- Diffuse needs the color pass but not lighting, scene composition, tone mapping, fog, or post effects.
- Material needs material output but not color composition or lighting.
- Depth/normal need the shared depth-normal pass only.
- AO needs depth, normal, emissive/mask data, and SSAO, but not direct lighting or post.
- Shadow/specular/indirect/reflection passes should enable only their actual dependencies.

This is a large win for multi-pass exports and also makes later G-buffer attachment selection straightforward.

### P1 — Consolidate camera geometry into a G-buffer

The color, depth/normal, material/emissive, and several effect-mask shaders repeat the same expensive setup:

- wind deformation in their vertex stages;
- model/view/projection transforms;
- base texture/alpha sampling and alpha hash;
- normal-map decoding;
- material-map decoding.

Examples are `shader_high_depth_normal` (`Asset/Shaders/shader_high_depth_normal.vsh:115-146`, `.fsh:45-60`) and `shader_high_material` (`Asset/Shaders/shader_high_material.vsh:61-82`, `.fsh:97-129`). Subsurface repeats the material decode yet again (`Asset/Shaders/shader_high_subsurface.fsh:35-98`).

#### Proposed layout

Use one feature-driven geometry pass for opaque and alpha-tested geometry. A conservative compatible layout is:

| Attachment | Suggested contents | Suggested format |
|---|---|---|
| Scene color | linear diffuse/color + alpha | `RGBA8` or `RGBA16F` only where truly needed |
| Depth | linear camera depth | `R32F` |
| Normal | octahedral normal in two channels | `RG16F` or `RGB10_A2` fallback |
| Material/effects | roughness, metallic/F0, emissive, compact flags/masks | `RGBA8` or `RGBA16F` when emissive range requires it |
| Optional effect attachment | glow/glint/SSS data only when enabled and not packable | capability/feature dependent |

This uses only multiple render targets and ordinary fragment outputs, which the current shader converter already handles for both D3D11 and OpenGL (`Asset/ShaderLoadD3D11.cpp:130-149`, `Asset/ShaderLoadOpenGL.cpp:38-60`). Existing code already binds MRTs (`Gml/RenderFunc.cpp:467-475`).

Important implementation constraints:

- **Split opaque/cutout and translucent queues.** A single blend mode across MRT attachments is not enough to preserve all current translucent ordering and packed-data semantics. Consolidate opaque/cutout geometry first; keep translucent objects on a smaller forward/fallback path until per-target blending is explicitly implemented and validated.
- **Only enable optional attachments for active features.** A wide G-buffer can be slower on low-end bandwidth-limited cards. Use a small set of shader/attachment profiles rather than one maximum-width layout.
- **Evaluate alpha/hash once per fragment.** The current separate passes can repeat alpha tests with the same sample seed. The consolidated pass should write all outputs after one alpha decision.
- **Encode per-object participation flags.** AO, fog, glint, glow, and scene masks currently get object-specific values through the repeated render modes. Preserve these as compact mask bits/channels rather than treating every visible pixel identically.
- **Share one hardware depth attachment across the G-buffer.** Current MRT binding already uses the first D3D framebuffer's DSV (`Render/GraphicsApiHandler.cpp:181-199`).

Expected result: the five unconditional/base camera traversals can approach one opaque traversal plus a translucent fallback. AO mask, fog mask, SSS inputs, and glow/glint sources can also avoid full scene replays where their semantics are encoded in the G-buffer.

### P1 — Move direct lighting to screen space

Current shadowed lighting redraws every visible object for every light, then copies the diffuse and specular results into accumulation surfaces. For each shadowed point or spot light, the lighting stage is followed by two full-screen additive draws (`Generated/Scripts49.cpp:500-562`). Sun lighting follows the same pattern (`Generated/Scripts49.cpp:412-434`). Shadowless points are batched 31 at a time, but every batch still redraws the full scene (`Generated/Scripts49.cpp:574-635`).

Once depth, normal, material, and scene color exist in the G-buffer:

- Reconstruct view/world position from depth, as SSAO and ray tracing already do (`Asset/Shaders/shader_high_ssao.fsh:39-50`, `Asset/Shaders/shader_high_raytrace.fsh:199-216`).
- Evaluate sun, point, and spot BRDFs in a full-screen or bounded screen-space pass using the existing shadow maps.
- Preserve the current GLSL-1.50-compatible uniform-array strategy for batches of shadowless points; do not require SSBOs or compute shaders.
- Restrict point/spot work using CPU-calculated screen-space rectangles or simple light-volume geometry. Full-screen loops over many lights can regress low-end GPUs even if they reduce draw calls.

#### Direct additive MRT accumulation

Write diffuse-light and specular-light targets directly with additive blending, avoiding the temporary MRT clear plus two apply draws. OpenGL's current blend function applies to all draw buffers, but D3D only initializes `RenderTarget[0]` in a blend state (`Render/GraphicsApiHandler.cpp:301-317`). Extend D3D blend-state creation to copy the desired state to every active output (or support explicit per-target states). This is standard D3D11/OpenGL functionality and needs no new shader version.

With deferred lighting, each light becomes at most one bounded draw rather than one complete scene redraw plus two full-screen draws. A shadowless batch becomes one bounded/full-screen draw independent of scene object count.

#### Preserve a hybrid path

Transparent/layered objects that cannot be represented correctly in the opaque G-buffer should remain forward-lit. A practical migration is:

1. Deferred opaque/cutout lighting.
2. Composite transparent geometry once using clustered/batched light data where possible.
3. Retain the old per-object path as a correctness fallback during rollout.

### P1 — Enable object batching in GLSL 1.50/4.00

The renderer already combines consecutive vertex buffers into one mesh and writes an object index into the high 16 bits of `Vertex::data` (`Render/VertexBufferRenderer.cpp:15-40`, `Render/VertexBufferRenderer.cpp:154-180`, `Render/Vertex.cpp:144-148`). D3D uses a constant-buffer object array. OpenGL uses an SSBO, but explicitly disables batching unless GL 4.3 is available (`Asset/ShaderLoadOpenGL.cpp:11-16`). Thus GLSL 1.50 and 4.00 modes fall back to one submission per vertex buffer because `Shader::SubmitObject()` forces a flush when batching is off (`Asset/Shader.cpp:568-586`).

Add an OpenGL uniform-buffer-object fallback:

- GLSL 1.50 supports uniform blocks; emit a `std140` object array for non-static per-object uniforms.
- Query `GL_MAX_UNIFORM_BLOCK_SIZE` and derive a smaller `batchBufferMaxObjects` per shader.
- Bind with `glUniformBlockBinding`; do not rely on GLSL 4.20 binding syntax.
- Continue using the existing flat object index carried from the vertex shader to the fragment shader.
- Keep SSBOs for GL 4.3 when available and the existing D3D constant-buffer path.

The field layout must be generated with explicit `std140` padding and matched by the CPU buffer writer. Matrix and `vec3` alignment are the main hazards. If a shader exceeds the minimum UBO capacity, split batches; correctness does not depend on a large block.

Also sort only the opaque render queue by shader/static texture/material state before feeding `VertexBufferRenderer`. `SubmitTexture()` flushes a batch when a sampler changes (`Asset/Shader.hpp:68-72`), so state sorting allows larger combined batches. Preserve the existing depth order for translucent objects.

This is the highest-value draw-call optimization specifically for GL 4.0/GLSL 1.50 cards, and it uses the current vertex format without a format change.

### P1 — Render point-shadow faces directly into the atlas

For every point light, each face is rendered into a single-face surface and then copied into the 3×2 atlas (`Generated/Scripts49.cpp:459-494`). That is six extra target transitions and six extra textured draws per point light.

Add a target-region/viewport API and render each face directly into its atlas tile:

- Bind the atlas once.
- Set a tile-sized viewport (and scissor for a tile clear).
- Render each of the six directions into its tile.
- Restore the full viewport afterward.

D3D11 viewports and OpenGL `glViewport`/`glScissor` are available at every targeted level. A 2D atlas retains the existing shader sampling and avoids cube-map-array requirements. Care must be taken to keep filtering inside a tile; the current shader already performs atlas-aware filtering.

Expected result per shadowed point light: six copy draws and most atlas/scratch target rebinding are removed. The six caster traversals remain until a more invasive single-pass layered shadow technique is introduced; such a technique is not recommended as a compatibility baseline.

### P1 — Replace copy-back chains with ping-pong ownership

The renderer frequently copies a source only because it wants to write the result back under the same surface ID. Make effect functions return the surface that owns the new result and swap logical roles instead.

Concrete cases:

- **Tone map:** render from `surf` into an alternate target and return the alternate target, removing the copy at `Generated/Scripts49.cpp:742-747`.
- **Reflections:** return the already-composited `render_surface_hdr[2]` instead of copying it into `surf` (`Generated/Scripts49.cpp:175-197`).
- **Fog:** sample base + fog mask and write one alternate output; remove the base-to-temp and temp-to-base copies (`Generated/Scripts48.cpp:739-775`). Fog application is only a mask/color operation (`Asset/Shaders/shader_high_fog_apply.fsh:1-10`) and can also be fused with tone mapping when ordering permits.
- **Post start:** if a scene/post phase has no enabled effects, return `prevsurf` immediately. If it does, let the first actual effect choose the alternate target instead of copying unconditionally (`Generated/Scripts49.cpp:112-134`).
- **Sample accumulation:** keep two sets of exponent/decimal/alpha accumulation surfaces. Read set A and write set B in the MRT accumulation shader, then swap. This removes the two/three `surface_copy()` calls at `Generated/Scripts49.cpp:226-232`.

The extra accumulation set costs memory, but avoids two or three full-resolution copies per sample. On constrained cards, make this selectable based on resolution/memory budget, or use a higher-precision accumulation format if testing proves it both accurate and cheaper.

### P1 — Remove clears before guaranteed overwrite

Many post passes clear a target and immediately shade every pixel. The clear is only needed because normal alpha blending can depend on the previous destination. Introduce an explicit replace/opaque post state (`src=one`, `dst=zero`), draw a full-screen triangle/quad, and skip the clear when the shader cannot discard and covers the target.

Candidates include chromatic aberration, distortion, color correction, grain, vignette, tone mapping, raytrace resolve, and simple copies. The current default `bm_normal` maps to source-alpha blending (`Gml/RenderFunc.cpp:78-86`), so this should be an intentional state change, not simply removal of clears.

Do not remove clears from partial, discarded, scissored, or additive passes without proving complete coverage.

### P2 — Use resolution-scaled blur pyramids

#### DoF CoC dilation

The CoC blur shader samples four texels on each side and is run horizontally and vertically 16 times (`Asset/Shaders/shader_high_dof_coc_blur.fsh:1-47`, `Generated/Scripts48.cpp:669-698`). That is 32 full-resolution passes just to dilate the front-blur mask.

Replace this with a max/weighted downsample pyramid and controlled upsample:

1. Generate CoC once.
2. Downsample with conservative front-CoC max and appropriate back-CoC aggregation.
3. Upsample/dilate through a small number of levels.
4. Feed the reconstructed CoC to the existing bokeh shader.

A four- or five-level pyramid touches far fewer pixels than 32 full-size passes and uses only ordinary 2D textures. Keep the current path as a high-accuracy comparison until near/far edge behavior matches.

#### Bloom, glow, and lens dirt

`shader_blur.fsh` supports up to 65 samples (`Asset/Shaders/shader_blur.fsh:1-48`), while glow and lens dirt each perform three horizontal/vertical radius passes at full resolution. Use half/quarter/eighth-resolution levels and composite weighted levels. Benefits are larger effective radii, fewer samples, and much lower bandwidth.

Do not blindly share one pyramid between effects with different source images. Share the implementation and transient surface pool; reuse actual pyramid contents only when the source and threshold semantics are identical. Bloom threshold, object glow, and lens accumulation are generally different sources.

Provide quality tiers:

- Low: half-resolution source, fewer levels/taps.
- Medium: half-resolution with bilateral/depth-aware upsample where needed.
- High: more levels or full-resolution first level.

All tiers can use the same GLSL 1.50/HLSL-compatible shaders.

### P2 — Run SSAO, indirect light, and reflections at real reduced resolution

Ray tracing currently shades a full-size target but skips alternating pixels (`Asset/Shaders/shader_high_raytrace.fsh:258-297`), then performs a full-size resolve (`Asset/Shaders/shader_high_raytrace_resolve.fsh:40-64`). Allocate a true half-resolution ray target, render all half-resolution pixels with sample jitter, and bilateral-upsample against full-resolution depth/normal.

The same pattern is suitable for SSAO, which takes 12 depth/normal samples per full-resolution pixel (`Asset/Shaders/shader_high_ssao.fsh:64-126`). Half-resolution SSAO plus bilateral upsample is likely preferable on low/mid cards. Keep full-resolution modes as quality options.

Subsurface scattering already has depth-aware rejection and can also use a scaled intermediate, though its visual sensitivity makes it a later candidate.

This reduces pixel/shader cost rather than draw count, but it materially improves layered-effect scenes.

### P2 — Fuse compatible pointwise post effects

The post chain applies CA, distortion, color correction, grain, vignette, and camera color overlay as separate full-screen passes (`Generated/Scripts49.cpp:849-885`). Most can be expressed in one shader while preserving order:

1. Compose the distortion transform into the coordinate used by chromatic aberration.
2. Sample the original source for CA at the transformed coordinate.
3. Apply color correction.
4. Add blue-noise grain.
5. Apply vignette.
6. Apply camera color transforms.

Watermark geometry can be drawn afterward into the same target. Use shader variants or generated feature defines for common combinations so low-end GPUs do not pay for disabled branches or the 32-iteration CA loop. The source shaders use only GLSL-1.50-compatible operations.

The CA shader itself takes up to 97 source samples per output pixel (32 iterations × RGB plus alpha; `Asset/Shaders/shader_ca.fsh:15-60`). Add a sample-count quality setting and fast path for zero blur. Reducing the CA loop can matter more than fusing its draw on low-end cards.

### P2 — Introduce descriptor-aware surfaces and cheaper formats

`FrameBuffer` currently supports only `RGBA8` and `RGBA32F` (`Render/FrameBuffer.cpp:38-51`, `Render/FrameBuffer.cpp:195-198`). It also allocates a D24S8 attachment whenever `depthBuffer` is true, while `surface_require()` defaults that parameter to true (`Generated/Scripts.hpp:7725`, `Generated/Scripts58.cpp:84-104`). Many post-only surfaces therefore carry unused depth/stencil storage.

Recommended changes:

- Add explicit surface descriptors: dimensions, color format, depth/stencil requirement, sampling role, and optionally transient lifetime.
- Use `RGBA16F` for HDR scene/light intermediates unless a measured effect requires 32-bit channels.
- Use `R32F` for linear sampled depth rather than RGB-packed depth. It uses the same four bytes as RGBA8, removes pack/unpack ALU, and simplifies reconstruction.
- Use `RG16F` octahedral normals or `RGB10_A2` where testing accepts the precision. The current normal buffer is `RGBA32F` and intentionally scales values by eight (`Generated/Scripts.hpp:158`, `Asset/Shaders/shader_high_depth_normal.fsh:20-23`), which is far more bandwidth than a normalized screen-space normal needs.
- Use `R8` for masks and CoC where precision is adequate.
- Allocate depth/stencil only for geometry targets that actually use depth/stencil testing.
- Recreate or reject a surface when its descriptor changes. Current `surface_require()` checks only existence and dimensions, not `depth` or `hdr` (`Generated/Scripts58.cpp:84-104`), so reuse can silently preserve the wrong format/attachment set.

Compatible mappings exist in both current APIs: for example D3D `R16G16B16A16_FLOAT`/OpenGL `RGBA16F`, D3D `R32_FLOAT`/OpenGL `R32F`, and D3D `R8_UNORM`/OpenGL `R8`. Keep `RGBA8`/`RGBA32F` fallbacks if capability checks fail.

Format reduction should follow correctness tests, especially for accumulated HDR samples, emissive range, normal precision, and transparent edges.

### P2 — Reduce renderer state and binding overhead

Even after reducing draw count, the hand-written abstraction does avoidable work per draw:

- `shader_set()` always submits, releases, binds, clears shader state, and resubmits matrices, even if the requested shader is already active (`Gml/RenderFunc.cpp:335-348`).
- OpenGL `Shader::SubmitVertices()` binds every active texture and calls `glTexParameteri` on every draw; the `changed` flag is cleared but not used to skip this work (`Asset/Shader.cpp:632-674`).
- D3D unbinds every sampler and SRV after every draw (`Asset/Shader.cpp:720-727`) and uploads static/object constant buffers wholesale (`Asset/Shader.cpp:690-704`).
- Every `surface_set_target()`/`surface_reset_target()` ends one framebuffer and begins another, frequently returning to the window between offscreen passes (`Gml/RenderFunc.cpp:437-495`).

Improve this by:

- making same-shader binds a no-op when no reset is required;
- retaining texture/sampler bindings and applying only dirty slots;
- on D3D, unbinding only SRVs that alias a render target about to be bound;
- uploading only dirty constant-buffer ranges or using a ring/dynamic buffer strategy;
- executing the high-quality render graph without resetting to the window framebuffer between dependent offscreen passes;
- caching MRT attachment sets and avoiding repeated heap allocation in OpenGL's `SetMRTIndex()` (`Render/GraphicsApiHandler.cpp:497-514`).

These changes are compatible with all targeted modes and particularly help GLSL 1.50 before/alongside UBO batching.

### P3 — Shadow reuse and culling

Shadow maps may be cached when all dependencies are stable: light/camera cascade state, caster transforms/visibility/material alpha, wind, alpha-hash sampling, and shadow settings. Current soft-shadow sampling deliberately jitters sun/light positions after early samples (`Generated/Scripts49.cpp:378-387`, `Generated/Scripts49.cpp:442-451`), so unconditional reuse would change output.

A safe initial cache is limited to hard, opaque shadows with zero light size/sun angle, no wind-animated casters, unchanged scene/light transforms, and no sample-dependent alpha hash. Dirty-region tracking and broad invalidation can be added later.

Also build a pass-independent visible/caster packet list once per sample. `render_world()` currently walks the ordered list for every render mode. Reusing culled packets and per-object resolved material state reduces CPU overhead even before draw calls are consolidated.

## Compatibility matrix

| Proposal | D3D11 / FL10 | OpenGL 4.3 | OpenGL 4.0 / GLSL 1.50 | Low-end behavior |
|---|---|---|---|---|
| MRT G-buffer | Yes | Yes | Yes | Limit attachments/format width by feature profile |
| Deferred fullscreen/bounded lights | Yes | Yes | Yes | Use scissor/light volumes and small uniform batches |
| Additive MRT | Yes, after applying blend state to all RTs | Yes | Yes | Same shaders; one draw/light or light batch |
| UBO object batching | Existing constant-buffer equivalent | SSBO or UBO | UBO | Smaller batches based on max block size |
| Point atlas viewport rendering | Yes | Yes | Yes | Removes copies without new texture types |
| Ping-pong surfaces | Yes | Yes | Yes | Trade optional extra memory for less bandwidth |
| Blur/downsample pyramids | Yes | Yes | Yes | Fewer levels/taps at low quality |
| Reduced-resolution SSAO/rays | Yes | Yes | Yes | Primary low/mid-card win |
| Fused post shader | Yes | Yes | Yes | Compile variants; lower CA samples |
| `RGBA16F`, `R32F`, `RG16F`, `R8` | Yes | Yes | Yes | Capability-tested fallbacks |

None of the recommended baseline changes requires compute shaders, SSBOs, image load/store, texture arrays, bindless textures, or indirect draw commands.

## Suggested implementation order

### Phase 1: establish measurements and apply independent fixes

1. Add per-pass counters for geometry traversals, vertex-buffer draws, primitive draws, target changes, pixels/resolution, and copied bytes.
2. Add GPU timestamp queries behind backend abstractions where supported, with CPU timers as fallback. Record each named `render_high` stage.
3. Fix the depth/normal condition.
4. Remove the duplicate CoC draw and reuse high-depth for DoF.
5. Cache kernels, DoF samples, and inverse matrices.
6. Replace dynamic grain generation with blue noise.
7. Skip `render_high_post_start()` when a phase has no active effects.
8. Add render-pass dependency masks and skip stages whose outputs are not requested.

This phase is low risk and establishes trustworthy before/after data.

### Phase 2: remove pure bandwidth waste

1. Add explicit replace blending for overwrite passes and remove safe clears.
2. Make tone map, reflections, fog, and post effects return/swap their output surface.
3. Ping-pong sample accumulation.
4. Render point-shadow faces directly into atlas viewports.
5. Add descriptor-aware/transient surfaces and remove unused depth attachments.

### Phase 3: reduce scene draw multiplication

1. Add GLSL-1.50 UBO batching and opaque state sorting.
2. Build the minimal opaque/cutout G-buffer.
3. Reuse its depth for all screen-space consumers.
4. Pack feature masks and remove AO/fog/SSS/glint/glow geometry replays one at a time.
5. Move direct lights to screen space and accumulate directly.
6. Keep transparent objects on the forward fallback, then optimize that queue separately.

### Phase 4: scale expensive effects

1. Replace DoF CoC dilation with a pyramid.
2. Move bloom/glow/lens dirt to scaled pyramids.
3. Add actual half-resolution SSAO and ray targets with bilateral upsample.
4. Fuse compatible post effects and add quality variants.
5. Evaluate shadow caching after correctness and timing data exist.

## Validation requirements

Performance work should be tested across:

- D3D11 feature levels 11 and 10 where available.
- OpenGL shader modes 430, 400, and 150.
- Integrated/low-end, mid-range, and high-end cards.
- Opaque-heavy, alpha-cutout-heavy, translucent/layered, many-light, many-shadow, and maximum-effect scenes.
- Transparent and solid backgrounds.
- Single sample and progressive multi-sample rendering.
- Render passes such as diffuse, material, depth, normal, AO, shadows, specular, indirect, and reflections—not only the combined output.

Track at least:

- scene traversals per sample;
- GPU draw calls per pass and total;
- target/MRT changes;
- full-screen pixels shaded;
- copied bytes;
- transient and persistent render-target memory;
- CPU render submission time;
- GPU time per stage;
- output differences at opaque edges, alpha-hashed layers, normal-mapped surfaces, fog boundaries, DoF transitions, glow/bloom radii, and progressive-sample convergence.

## Expected priority by bottleneck

| Bottleneck | Highest-value changes |
|---|---|
| CPU/draw-call limited scenes | GLSL 1.50 UBO batching, opaque sorting, G-buffer consolidation, deferred lighting |
| GPU vertex limited scenes | G-buffer consolidation, deferred lighting, shadow caching/culling |
| GPU bandwidth limited scenes | Ping-pong ownership, remove copies/clears, scaled pyramids, cheaper formats, no unused depth attachments |
| GPU fragment limited scenes | Reduced-resolution SSAO/rays, bounded lights, lower CA samples, blur pyramids |
| Many shadowed point lights | Direct atlas rendering, caster culling, deferred light apply, conditional cache |
| Many layered effects | Fused post, shared transient pyramid system, blue-noise grain, no-op phase skipping |

## Bottom line

The key issue is not a single slow shader. It is that `render_high()` repeatedly asks the renderer to redraw the same scene and repeatedly moves full-resolution images between surfaces. The best architecture for every requested backend is a hybrid deferred pipeline: one feature-sized G-buffer for opaque/cutout geometry, bounded screen-space direct lights, a forward fallback for difficult transparency, and a render graph that swaps transient targets rather than copying them back. The existing MRT support, shader translation layer, packed object index, and 31-light uniform batching provide most of the foundation; extending those mechanisms is both more compatible and more valuable than introducing a GL-4.3-only compute path.
