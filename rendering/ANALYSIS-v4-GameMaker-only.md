Prompt:

*Investigate performance optimizations and opportunities for reducing repeated draw calls, limiting the scope to GmProject only. The focus should be on improving the rendering speed in GameMaker's VM of 3D scenes with many layered effects in render_high(). New proposed shader functionality or format changes should be compatible with both GameMaker's API and run on low-to-high end cards. For now, disregard the YYC target and references to C++ conversion in the project (such as CppSeparate in scripts), instead treat it as a standalone GameMaker project for Windows.*

# GameMaker rendering performance analysis

Date: 2026-08-26  
Scope: `GmProject` only, standalone GameMaker project for Windows, VM target  
Excluded: YYC, C++ conversion paths, and `CppSeparate`

## Executive summary

The main bottleneck is not a single expensive shader. `render_high()` repeatedly traverses and resubmits the entire scene to produce data that is already present, or could be emitted alongside an existing pass. In the GameMaker VM, each traversal also repeats GML-side object iteration, string-keyed uniform lookups, texture-state queries, matrix setup, and `vertex_submit()` calls.

A representative frame with a background, sun shadows, one shadowed point light, one shadowed spot light, SSAO, subsurface scattering, fog, depth of field, and both glow variants performs about **24 whole-world traversals per temporal sample**:

| Work | Whole-world traversals |
|---|---:|
| Diffuse, depth/normal, material | 3 |
| Sun: 3 shadow cascades + lighting | 4 |
| One point light: 6 cubemap faces + lighting | 7 |
| One spot light: shadow + lighting | 2 |
| SSAO mask | 1 |
| Subsurface data | 1 |
| Glint + scene mask | 2 |
| Fog mask | 1 |
| DOF depth | 1 |
| Glow + glow falloff source | 2 |
| **Total** | **24** |

This is a static submission count, not a measured driver draw-call count. GameMaker may batch some built-in draws, but shader, uniform, target, blend-state, primitive, and `vertex_submit()` boundaries limit that batching. No project build or runtime profile was performed.

The recommended direction is a **hybrid renderer**:

1. Preserve the existing ordered forward path for genuinely blended or custom-blend geometry.
2. Move opaque and alpha-hashed geometry to compact MRT data passes and deferred/local-volume lighting.
3. Derive screen effects from depth, normal, material, and packed flags instead of redrawing the world.
4. Fuse full-screen effects and use a downsample pyramid for bloom, glow, lens dirt, and DOF support buffers.
5. Remove VM hot-path map/string lookups and redundant state calls.

This keeps the implementation within GameMaker's portable GLSL ES feature set and provides RGBA8 fallbacks for low-end cards.

## Current render path

The main temporal-sample path is in [`render_high.gml`](../GmProject/scripts/render_high/render_high.gml). For every new sample it invokes base passes, shadows, indirect light, SSAO, scene composition, reflections, tone mapping, fog, post effects, and sample accumulation. After all samples are complete, it still unpacks and reruns the final post chain on subsequent frames.

The first major multiplication happens in [`render_high_passes.gml`](../GmProject/scripts/render_high_passes/render_high_passes.gml):

- Diffuse is a whole-world pass.
- Alpha correction can be another whole-world pass when no background is rendered.
- Depth and normals are a second whole-world pass using two MRT outputs.
- Material and emissive are a third whole-world pass using two MRT outputs.

[`render_high_scene.gml`](../GmProject/scripts/render_high_scene/render_high_scene.gml) then redraws the world for glint and again for the scene/background mask before its full-screen lighting composite.

[`render_high_shadows.gml`](../GmProject/scripts/render_high_shadows/render_high_shadows.gml) is the largest scene-dependent multiplier:

- Sun shadows render three complete cascades, then traverse the world again to shade the sun.
- Each shadowed point light renders six complete cubemap faces, then traverses the world again to shade the light.
- Each shadowed spot light renders one shadow map, then traverses the world again to shade the light.
- Shadowless lights are grouped in batches of up to 31, but each batch still runs a whole-world lighting pass.
- Subsurface scattering adds another whole-world data pass.

Every `render_world()` call loops the full render list in [`render_world.gml`](../GmProject/scripts/render_world/render_world.gml). The standalone GameMaker path does not currently perform useful spatial culling: `update_frustum()` is empty in [`util_cpp.gml`](../GmProject/scripts/util_cpp/util_cpp.gml), while the existing frustum library constructs planes but is not used to reject model or scenery bounds.

## Highest-priority fixes

### 1. Correct the depth/normal enable condition

[`render_start.gml`](../GmProject/scripts/render_start/render_start.gml) uses:

```gml
project_render_subsurface_samples >= 0
```

as part of `render_depth_normals`. Since zero means no subsurface scatter pass elsewhere, this condition keeps depth/normal rendering enabled even when every actual consumer is disabled. It should be gated by the real consumers and use `> 0` for subsurface samples.

Expected effect: removes one full scene traversal in configurations with depth-based effects disabled. This is a small code change and should be addressed first.

### 2. Replace CPU/VM-generated grain

[`render_generate_noise.gml`](../GmProject/scripts/render_generate_noise/render_generate_noise.gml) creates noise with nested GML loops and one `draw_point_color()` call per texel. [`render_high_grain.gml`](../GmProject/scripts/render_high_grain/render_high_grain.gml) invokes it for the grain surface. A 240×240 noise tile results in 58,081 loop iterations and point submissions because both loops include the endpoint.

Use the existing blue-noise asset or a small pre-created noise texture, then vary UV offset, rotation, and/or channel selection per frame/sample in the grain shader. This eliminates a large VM-only workload without changing scene rendering.

Expected effect: potentially one of the largest immediate CPU wins whenever film grain is enabled.

### 3. Remove redundant DOF work

[`render_high_dof.gml`](../GmProject/scripts/render_high_dof/render_high_dof.gml) redraws the entire scene for depth even though `render_surface_depth` already exists. It then draws both a blank quad and the previous surface while the circle-of-confusion shader only needs the depth texture. It also performs 16 horizontal/vertical full-resolution blur iterations: 32 full-screen passes.

Changes:

- Reuse `render_surface_depth`.
- Draw the CoC shader once, using a frozen full-screen primitive.
- Generate CoC at half or quarter resolution.
- Replace 16 full-resolution iterations with a small separable dilation/max-filter or a few Kawase iterations.
- Cache the bokeh sample-offset array and upload it only when blade/quality settings change; rotate it per sample with one uniform.

Expected effect: removes one whole-world traversal, one redundant full-screen draw, and most DOF bandwidth.

### 4. Render the glow source once

[`render_high_glow.gml`](../GmProject/scripts/render_high_glow/render_high_glow.gml) rerenders the world to obtain a glow source. Normal glow and glow falloff call this path independently even though only their blur radius/intensity differs.

Render one glow source and reuse it for both outputs. In the medium-term MRT consolidation described below, emit glow alongside material/emissive data so no dedicated glow scene traversal remains.

### 5. Stop reprocessing completed temporal output

When `render_samples_done` is true, [`render_high.gml`](../GmProject/scripts/render_high/render_high.gml) still unpacks the accumulator, copies surfaces, and executes the full final post chain each frame.

Cache the static resolved result. If film grain or another explicitly time-varying final effect is enabled, rerun only one lightweight merged final shader. Invalidate the cache on camera, timeline, render setting, viewport, or scene changes.

## Reduce geometry submissions

### Add GML-side frustum and light-volume culling

The model format already retains bounds, and scenery has size data. Use those to create conservative AABBs or spheres and build visible lists before each view:

- Main camera frustum.
- Each sun cascade.
- Each point-light face, additionally rejecting objects outside the light radius before face tests.
- Each spot-light frustum.

Cache the main-camera visible list across a temporal sequence; small TAA jitter should use a conservatively expanded frustum rather than rebuilding visibility. Particle emitters need conservative bounds or an uncullable fallback.

This does not reduce the number of logical passes, but it can reduce `vertex_submit()` calls inside every pass and is especially valuable before or during the shadow redesign.

### Batch repeated scenery geometry

[`render_world_scenery.gml`](../GmProject/scripts/render_world_scenery/render_world_scenery.gml) repeats X/Y/Z loops and resubmits the same block buffers for every repeated cell in every pass. When repeat counts or scenery data change, generate a combined frozen vertex buffer for the repeated arrangement. The steady-state submission count then becomes the number of material/buffer groups rather than `repeat_x × repeat_y × repeat_z × groups`.

### Merge static compatible model shapes

[`render_world_model_part.gml`](../GmProject/scripts/render_world_model_part/render_world_model_part.gml) submits each shape independently. At model load or geometry invalidation, combine static shapes that share shader-relevant material, texture, culling, blend, and animation state. Keep transparent ordering and independently animated shapes separate.

### Separate opaque/hashed and blended queues

Opaque and alpha-hashed geometry can be sorted by shader, material, texture, and vertex buffer to reduce state changes. Truly blended/custom-blend geometry must preserve its required depth order.

This separation is also necessary for safe deferred rendering: a single depth/material value cannot represent several genuinely blended layers. The project default is `e_alpha_mode.BLEND`, while `HASHED` is an optional mode, so a universal deferred conversion would be incorrect.

## Consolidate world-data passes with MRT

GameMaker's native Windows targets expose MRT indices 0–3 through `surface_set_target_ext()`. The existing renderer already uses two MRT outputs, so extending this approach does not introduce a new platform dependency.

However, GameMaker exposes one global blend state for the active targets. Diffuse uses alpha blending, depth/normal use overwrite blending, and material/emissive currently use normal blending. Therefore, one universal four-output “mega G-buffer” would change blended-layer semantics.

Use two compatibility levels:

### Safe baseline

Keep the diffuse pass separate. Extend the material/emissive pass to four targets:

1. Material.
2. Emissive.
3. Glint.
4. Glow source.

Pack scene flags into otherwise unused or redesigned channels so SSAO eligibility, fog eligibility, sky/background, reflection eligibility, and similar binary masks can be tested in screen-space shaders. Subsurface strength can use material alpha if its range is normalized or logarithmically encoded; radius may require an optional auxiliary target/pass when SSS is enabled.

This removes dedicated glint, scene-mask, AO-mask, fog-mask, and repeated glow traversals while preserving the existing diffuse blend behavior.

### Opaque/hashed fast path

For opaque and alpha-hashed buckets, combine depth, normal, material, and emissive into four MRT outputs under overwrite semantics. Keep diffuse separate, or redesign its destination only after verifying identical alpha behavior. Blended/custom-blend objects continue through the compatibility path.

At runtime, verify that the MRT target setup succeeds; retain the current separate-pass path as a fallback.

## Change lighting to a hybrid deferred path

The renderer already has depth, normal, material, emissive, and shadow textures, but direct lighting redraws scene geometry for each sun/local-light group. For opaque and alpha-hashed pixels:

- Reconstruct view/world position from depth.
- Shade the sun with one full-screen triangle.
- Shade point lights with camera-clipped sphere volumes.
- Shade spot lights with cone volumes.
- Use additive blending directly into lighting/specular targets.
- Avoid temporary diffuse/specular surfaces followed by two full-screen add passes per light.

Keep the existing forward-light shaders for truly blended/custom-blend geometry. This hybrid is the important compatibility boundary for layered scenes.

Shadow-caster passes remain, but culling greatly reduces their submissions. A shadowed point light still needs six faces in the compatible cubemap approach. Dual-paraboloid shadows could reduce this to two passes, but seam/distortion and quality tradeoffs make that an optional aggressive tier rather than a first implementation.

For static geometry and lights with zero soft-shadow radius, cache shadow maps across temporal samples and invalidate them only when relevant geometry, animation, wind, or light transforms change.

## Full-screen pass and bandwidth reductions

### Replace copy-back functions with surface ownership

Tone mapping, reflections, fog, and several post functions copy the source to a temporary, draw to a destination, then copy back. Track `current_surface` and return the destination surface from each pass. With two post ping-pong surfaces, most copy-back operations disappear.

[`render_high_post_start.gml`](../GmProject/scripts/render_high_post_start/render_high_post_start.gml) should not eagerly duplicate the source before knowing an effect needs a different target. The top-level copies around `render_post()` can likewise be routed so the last effect writes to the required destination.

When a pass fully overwrites its target and has no discard path, use overwrite blending and omit the preceding clear.

### Fuse lightweight post effects

[`render_post.gml`](../GmProject/scripts/render_post/render_post.gml) sequentially applies chromatic aberration, distortion, color correction, grain, vignette, and camera-color overlay, with a separate full-screen pass and state transition for each.

Merge these into one GLSL ES shader with enable uniforms and preserve their current operation order inside the fragment shader. Keep watermark/compositing that requires a separate texture or distinct blend semantics separate.

### Use one downsample pyramid

[`render_high_bloom.gml`](../GmProject/scripts/render_high_bloom/render_high_bloom.gml), [`render_high_glow.gml`](../GmProject/scripts/render_high_glow/render_high_glow.gml), and [`render_high_lens_dirt.gml`](../GmProject/scripts/render_high_lens_dirt/render_high_lens_dirt.gml) perform many full-resolution, high-tap blur passes. Bloom alone can submit several dozen full-screen draws at higher blade settings.

Build one half/quarter/eighth/sixteenth-resolution luminance/glow pyramid, use small separable or Kawase kernels, and combine levels in one final pass. Lens dirt should consume an existing blurred bright level instead of running its own six-pass 65-tap blur chain. Keep the current full-resolution path only as an optional maximum-quality mode if visual comparison warrants it.

## Temporal accumulation and surface formats

[`render_high_samples_add.gml`](../GmProject/scripts/render_high_samples_add/render_high_samples_add.gml) uses multiple RGBA8 surfaces as a packed fixed-point accumulator, copying them into temporary surfaces before a full-screen MRT pack/add step for every sample. [`render_high_samples_unpack.gml`](../GmProject/scripts/render_high_samples_unpack/render_high_samples_unpack.gml) adds another full-screen pass.

On hardware that reports `surface_rgba16float` support:

- Accumulate samples additively into one RGBA16F surface.
- Resolve/divide once when presenting the current accumulation.
- Retain the current packed RGBA8 path as a fallback.

Do not make RGBA32F the default; it consumes more bandwidth and has weaker low-end support. Probe support once at startup with `surface_format_is_supported()` and cache a capability struct.

The standalone helper [`util_cpp.gml`](../GmProject/scripts/util_cpp/util_cpp.gml) currently implements `surface_create_ext2(width, height, depth, hdr)` as plain `surface_create(width, height)`, ignoring both `depth` and `hdr`. For the standalone Windows project, make this helper honor requested formats and depth-buffer policy:

- RGBA8 baseline for LDR color.
- R8 or RG8 for masks/CoC where supported and valid for the target combination.
- RGBA16F for HDR/accumulation when supported.
- Depth only on surfaces that actually require depth testing; post-process surfaces should not each receive an unused depth/stencil buffer.

Use `surface_depth_disable()` around creation where appropriate and restore the previous policy immediately afterward.

## Reduce GameMaker VM-side state overhead

The inner rendering path repeatedly does work that should be resolved once:

- [`render_set_uniform.gml`](../GmProject/scripts/render_set_uniform/render_set_uniform.gml) and its variants look up uniform names in a DS map for every set.
- [`render_set_texture.gml`](../GmProject/scripts/render_set_texture/render_set_texture.gml) constructs a sampler name, performs map lookup, queries current GPU sampler state, then reapplies bindings/state.
- [`render_world_tl_reset.gml`](../GmProject/scripts/render_world_tl_reset/render_world_tl_reset.gml) performs large batches of reset/upload calls multiple times per world traversal.
- [`draw_blank.gml`](../GmProject/scripts/draw_blank/draw_blank.gml) rebuilds a four-vertex immediate primitive for every full-screen operation.

Changes:

1. Resolve uniform and sampler handles when each shader object is created; store direct fields or indexed arrays.
2. Pass handles to hot-path setters instead of strings.
3. Maintain a renderer-owned state cache for shader, texture per stage, filtering, repeat, mip filtering, blend, cull, depth write/test, and target. Call the GameMaker API only when desired state differs.
4. Never call GPU state getters from the per-object texture bind path; update the cache whenever this renderer changes state.
5. Make `render_world_tl_reset()` cache-aware and invoke it only at boundaries that can actually dirty those values.
6. Create and freeze one full-screen triangle vertex buffer and reuse it for all screen-space passes.

## Alpha handling

The diffuse pass currently performs an additional alpha-fix operation. GameMaker exposes separate RGB and alpha blend factors. For standard alpha-blended geometry, test replacing the repair pass with accumulated-alpha blending during the original diffuse draw:

```gml
gpu_set_blendmode_ext_sepalpha(
    bm_src_alpha, bm_inv_src_alpha,
    bm_one,       bm_inv_src_alpha
);
```

This produces normal source-over RGB while accumulating destination alpha. Custom blend modes must remain on their existing path until verified; the optimization should be enabled per compatible render bucket, not globally assumed.

## Compatibility requirements

All proposed baseline shaders can remain GLSL ES 1.00 and use only:

- Up to four 2D MRT outputs.
- Ordinary 2D samplers.
- Existing vertex/fragment stages.
- Basic uniforms, matrices, and blend/depth states.

Avoid compute shaders, SSBOs, geometry shaders, texture arrays, sampler arrays, atomics, and other features outside GameMaker's cross-target shader model.

Recommended capability tiers:

| Tier | Features |
|---|---|
| Baseline | RGBA8 data surfaces, current packed sample accumulation, fused shaders, culling, state cache, sub-resolution effects |
| Enhanced | RGBA16F HDR/sample accumulation; R8/RG8 masks where supported |
| Fallback | Current separate data passes when MRT setup or a required shader does not compile |

Check `shader_is_compiled()`, `surface_format_is_supported()`, and target-binding success at startup. Store the selected path instead of probing inside render loops.

## Suggested implementation order

### Phase 1: low-risk VM and redundant-work fixes

1. Correct the depth/normal enable condition.
2. Replace generated grain with sampled blue noise.
3. Reuse existing depth in DOF and remove the redundant CoC draw.
4. Cache DOF kernels.
5. Reuse one glow source for normal/falloff glow.
6. Skip static resolve/post work after temporal completion.
7. Reuse a frozen full-screen triangle.

### Phase 2: bandwidth and state

1. Implement source/destination surface ownership and remove copy-backs.
2. Fuse the lightweight final post chain.
3. Use no-depth post surfaces and capability-selected formats.
4. Add the uniform/sampler handle cache and renderer state cache.
5. Introduce the shared sub-resolution bloom/glow/lens-dirt pyramid.

### Phase 3: geometry reduction

1. Add camera/light/cascade culling.
2. Cache repeated scenery buffers and merge compatible static shapes.
3. Split opaque/hashed and blended render queues.
4. Extend compatible MRT data outputs and pack screen-effect flags.

### Phase 4: hybrid deferred lighting

1. Deferred sun lighting for opaque/hashed pixels.
2. Point/spot light volumes.
3. Preserve forward lighting for blended/custom-blend geometry.
4. Add static hard-shadow caching.
5. Consider dual-paraboloid point shadows only after quality/performance evaluation.

## Expected impact

The representative 24-traversal sample can be reduced approximately as follows:

- Screen-effect masks, DOF depth, glint, and repeated glow sources: removed from world traversal.
- Direct-light shading passes: replaced by screen/light-volume draws for opaque/hashed geometry.
- Remaining major world traversals: diffuse/data passes plus 3 sun shadow cascades, 6 point faces, 1 spot shadow, and the blended compatibility path.

Without changing point-shadow representation, this roughly halves whole-world traversal count in the representative case before accounting for culling. Scenes with many shadowless local lights or many enabled screen effects benefit more. Scenes dominated by one shadowed point light remain constrained by its six shadow views, making per-face culling and caster batching essential.

## Validation plan

When implementation begins, profile a fixed Windows VM scene at identical resolution and render settings. Record separately:

- CPU frame time and `render_high()` time.
- Number of `render_world()` traversals.
- `vertex_submit()` count.
- Surface target switches and full-screen submissions.
- GPU frame time at 720p, 1080p, and 4K.
- VRAM/surface allocation by format and depth policy.
- Visual difference images for blend mode, hashed alpha, transparent backgrounds, fog, DOF edges, glow, reflections, and every shadow type.

Use at least one low-end integrated GPU, one mid-range GPU, and one higher-end GPU. Every enhanced-format or MRT path must be exercised with its forced fallback.

## Official GameMaker API references

- [Multiple render targets (`surface_set_target_ext`)](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/surface_set_target_ext.htm)
- [Surface creation and supported formats](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/surface_create.htm)
- [Surface format capability check](https://manual.gamemaker.io/beta/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/surface_format_is_supported.htm)
- [Surface depth allocation policy](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/surface_depth_disable.htm)
- [GameMaker shader language/platform support](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Asset_Management/Shaders/Shaders.htm)
- [Rendering/batching best practices](https://manual.gamemaker.io/monthly/en/Additional_Information/Best_Practices_When_Programming.htm)
- [Frozen vertex buffers](https://manual.gamemaker.io/monthly/en/GameMaker_Language/GML_Reference/Drawing/Primitives/vertex_freeze.htm)
- [Separate RGB/alpha blend factors](https://manual.gamemaker.io/beta/en/GameMaker_Language/GML_Reference/Drawing/GPU_Control/gpu_set_blendmode_ext_sepalpha.htm)
- [Blend-mode guide](https://manual.gamemaker.io/monthly/en/Additional_Information/Guide_To_Using_Blendmodes.htm)

