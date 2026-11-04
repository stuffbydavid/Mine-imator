# Standard renderer optimization review

## Scope and conclusion

This review revisits rendering analyses v1-v5 and v7, excluding the startup analysis. It checks their recommendations against the current GML orchestration, shader sources, and handwritten C++ engine, and identifies additional opportunities introduced or exposed by the subsequent changes. No build or application run was performed.

**The next substantial Standard sunlight improvement should combine earlier caster rejection with a smaller, specialized sun shader.** To reduce whole-world traversals, follow with correctly invalidated Standard shadow caching and selective consolidation of scene-mask/fog data. Deferred sunlight remains valuable but requires more work for visual parity than v7 suggests.

The strongest new opportunities are excluding pass-wide shadow texture coordinates from object records and making Standard's auxiliary outputs match their actual consumers. These are more targeted than another general texture-atlas or batching rewrite.

Judge acceptance using the optimized **C++ product**, on D3D and OpenGL. GML changes matter because their converted code controls C++ rendering. GameMaker VM timings, VM call overhead, and developer-only fallback limitations must not determine the priority order.

## What the current Standard path actually does

[render_start](../GmProject/scripts/render_start/render_start.gml) and [render_apply_settings](../GmProject/scripts/render_apply_settings/render_apply_settings.gml) configure Standard as a single-sample high-quality render with FXAA, no screen-space indirect lighting or reflections, and no jittered shadows. [render_high](../GmProject/scripts/render_high/render_high.gml) still invokes the same major data and lighting stages as Realistic.

For a normal combined output, without camera-texture renders or editor overlays:

| Stage | `render_world()` calls per Standard image |
| --- | ---: |
| Diffuse, scene lighting mask, combined G-buffers | 3 |
| Auxiliary fog/SSS/glow data, if requested | 1 |
| Sun shadow maps | C, the cascade count |
| Sun lighting | 1 |
| Each shadowed point light | 7: six depth faces and one lighting pass |
| Each shadowed spot light | 2 |
| Each shadowless spot light | 1 |
| Shadowless point lights | One per group of up to 31 |

All sunlight/local-light rows require `render_shadows`; sunlight additionally requires the existing `sunout` test to pass. Counting only the lights actually dispatched, the general cold-render count is therefore:

`3 + auxiliary + sun * (C + 1) + 7 * shadowedPoints + 2 * shadowedSpots + shadowlessSpots + ceil(shadowlessPoints / 31)`

With sunlight and auxiliary data but no local lights, one/two/three cascades mean **6/7/8 world traversals**. Without auxiliary data, subtract one. SSAO and DOF no longer add their own world traversal.

These are orchestration counts, not GPU draw counts. [VertexBufferRenderer](../CppProject/Render/VertexBufferRenderer.cpp) can combine many vertex submissions into one API draw. Conversely, texture, sampler, culling, depth, shader, and target changes can split a batch within one traversal.

Sun cascades remain view-dependent. [render_update_cascades](../GmProject/scripts/render_update_cascades/render_update_cascades.gml) uses camera position/orientation, FOV, aspect, clipped distance and texel snapping. One cascade is not automatically reusable between different cameras merely because sunlight has not moved.

## Status of the earlier recommendations

| Earlier recommendation | Current assessment |
| --- | --- |
| Correct the always-enabled `render_depth_normals` expression | Superseded: that switch/path is gone. The current combined G-buffer has material/glint and lighting consumers; deleting it on the old condition would be wrong |
| Combine depth/normal/material/emissive and effect masks | Substantially implemented through `G_BUFFERS` and `AUXILIARY`; diffuse and `SCENE_TEST` remain separate |
| Reuse depth for DOF and remove duplicate CoC draw | Implemented in [render_high_dof](../GmProject/scripts/render_high_dof/render_high_dof.gml); the old 16-iteration CoC blur is also now one horizontal/vertical pair |
| Avoid separate glow-source world renders | Implemented: [render_high_glow](../GmProject/scripts/render_high_glow/render_high_glow.gml) reads auxiliary glow data |
| Replace packed sample accumulation | Implemented: [render_high_samples_add](../GmProject/scripts/render_high_samples_add/render_high_samples_add.gml) adds into RGBA32F on C++; irrelevant to Standard's one-sample path |
| Replace RGBA32F intermediates with smaller formats | Substantially implemented: RGBA16F lighting/normals, R32F depth/shadows, R8 fog, R16F SSS; [FrameBuffer](../CppProject/Render/FrameBuffer.cpp) supports explicit formats |
| Pool surfaces by render owner | Implemented in [render_surface_pool_set](../GmProject/scripts/render_surface_pool_set/render_surface_pool_set.gml); descriptor validation and unused attachments remain opportunities |
| Bloom/glow blur pyramids | Implemented via [render_blur_pyramid](../GmProject/scripts/render_blur_pyramid/render_blur_pyramid.gml); lens dirt still has its own full-resolution blur chain |
| Floating-point array leak and temporary upload allocations | Matrix/float scratch arrays are reused; D3D sampler/SRV arrays now use fixed storage in [Shader.cpp](../CppProject/Asset/Shader.cpp) |
| Implement `gpu_set_blendenable` | Implemented in [RenderFunc.cpp](../CppProject/Gml/RenderFunc.cpp) and [GraphicsApiHandler.cpp](../CppProject/Render/GraphicsApiHandler.cpp) |
| Improve atlas batching and instance repeated meshes | Substantially implemented: per-object UV rectangles, pack-local sprite/resource copies, and instancing for repeated single meshes at/above the combined-batch size limit |
| Cull before batching, optimize bounds math, hash batch lookup | Only partly addressed: the new instancing path pre-culls; ordinary combined batches still use aggregate culling and linear cache lookup |
| Specialize sun cascades/PCSS, add sampleable hardware depth | Still relevant; current sun shader always carries three cascades and shadows still allocate color plus hardware depth |
| Cache shadow maps | Present for eligible Realistic sampling, not enabled for Standard; reuse needs revision tracking for Standard playback/view updates |
| Deferred sun/local lighting and point-atlas direct rendering | Still unimplemented; transparency and stored material semantics require a staged approach |
| State/resource caches, GL fallback batching | Still relevant: GL without 4.3 disables object batching; D3D reuploads/rebinds and unbinds resources on each draw |
| Replace CPU-generated grain, cache SSAO/DOF kernels | Still relevant but secondary to Standard sunlight and scene submission |
| Remove copy-backs and final resolved-image work | Partial: tonemapping/effects return surfaces, but fog, post-start and final output still contain copies; converged Realistic output is outside this report's main priority |

The earlier advice to precombine every repeated scenery/model buffer should be downgraded. C++ already combines compatible small buffers and instances large repeated ones. Additional geometry duplication needs evidence of CPU construction/cache cost or capacity-driven batch splitting, rather than a GameMaker `vertex_submit()` count.

## Implementation priorities

### P0: measure actual pass and batch boundaries

Add optional per-pass C++ counters for API draws, submitted triangles, candidate/culled objects, combined/instanced batches, batch capacity, and uniform upload bytes. Label the pass with renderer, render owner, sample, light and cascade. Record batch-flush reasons at the points that request them: physical texture change, filtering/mip bias, repeat state, culling/depth/blend, shader/target transition, object capacity and index capacity.

Keep both per-sample and whole-image world-call totals. Reset/snapshot GPU submission counters explicitly around an output after flushing pending work, and include primitive draws so a vertex-buffer-to-fullscreen conversion cannot appear to eliminate all draws. The single-buffer path currently adds the entire buffer's triangle count if any mesh draws, so buffers with partially culled meshes also need more precise triangle accounting.

Add asynchronous GPU timing around cascades and sunlight shading, collecting completed results later. There is no pass-level GPU timestamp instrumentation in the current handwritten engine. Keep CPU submission, GPU execution, surface allocation, readback and PNG encoding separate.

This is a prerequisite for ranking PCSS versus geometry work, not a requirement to postpone the small, provably redundant operations below.

### P1: reject sunlight casters before ordinary batches are built

This remains the strongest geometry-side recommendation from v7, with an important update: [VertexBufferRenderer::Add](../CppProject/Render/VertexBufferRenderer.cpp) already pre-culls large instanced meshes. Small objects still enter a combined batch unconditionally. `SubmitBatch` searches/builds the combined GPU mesh before testing its union bounds.

Recommended sequence:

1. Reject a fully invisible aggregate before cache search or `CreateBuffers`, with the same object-state reset the existing rejection path performs
2. Replace allocating eight-corner transforms/tests in [Bounds.cpp](../CppProject/Render/Bounds.cpp) and `GraphicsApiHandler::IsVisible` with affine center/extents bounds and plane tests
3. Apply conservative per-object culling before appending to ordinary combined batches
4. Cache transformed bounds until the matrix or geometry revision changes
5. Build a shadow-caster candidate list so rejected timelines avoid the expensive material/resource setup preceding C++ submission

Use the light cascade volume, not the camera frustum: an off-screen object can cast an on-screen shadow. Include wind displacement, animated/bent geometry, billboard transforms and particle bounds; use a conservative fallback when no valid bound exists. Current mesh bounds originate from undeformed vertices, so simply applying the existing test to every small object is not a correctness-complete implementation.

Visibility-dependent batch sequences can increase cache churn. Profile that tradeoff before introducing finer spatial clusters. For surviving combined batches, replace the linear `activeBatches` search with a hash of the ordered mesh-ID sequence and geometry revision, retaining equality verification. Do not force one batch per spatial cell just to improve culling statistics.

Expected impact: less vertex processing and CPU work in every cascade; fewer API draws when complete batches disappear. World-call count is unchanged.

Also remove the unused `cam_frustum.build()`/`build_vbuffer()` in `render_update_cascades`. The only other `cam_frustum` references initialize it. The helper destroys/recreates a debug mesh on each update without a consumer. This saves allocation/construction, not a visible draw.

### P1: specialize the sun shader and stop duplicating surface UVs per object

The old cascade recommendation remains valid. [shader_high_light_sun](../GmProject/shaders/shader_high_light_sun/shader_high_light_sun.fsh) and its [vertex shader](../GmProject/shaders/shader_high_light_sun/shader_high_light_sun.vsh) always declare three cascades, calculate three shadow coordinates and three receiver-depth gradients. [shader_high_light_sun_set](../GmProject/scripts/shader_high_light_sun_set/shader_high_light_sun_set.gml) aliases the missing cascades to existing maps.

Compile one-, two- and three-cascade variants, plus a hard-shadow variant for zero quality/blur. Start with those few variants before multiplying quality buckets. Quality 20 can perform one center, ten blocker and twenty filter depth reads per affected fragment; specializing cascade count alone does not remove that PCSS cost. Retain early blocker-free rejection and benchmark smaller bounded quality kernels at comparable image quality.

**New extension:** [Shader::LoadCodeCommon](../CppProject/Asset/Shader.cpp) adds an object UV rectangle for every sampler in a batched shader. The three sun depth buffers are standalone surfaces with fixed full-image rectangles throughout the pass, yet each consumes a `vec4` in every object record. Separate atlas-varying samplers from pass-constant surface samplers. Keeping the three depth rectangles out of the object record removes 48 bytes of logical object payload before any overall layout adjustment; it also removes the corresponding object writes. D3D batch capacity is calculated from the object stride in [ShaderLoadD3D11](../CppProject/Asset/ShaderLoadD3D11.cpp).

Use an explicit sampler classification, not the existing `// static` on a sampler declaration: diffuse/material/normal samplers already have that annotation but still require per-object atlas rectangles. Preserve the sampler's texture, UV orientation and repeat behavior on both backends. Similarly audit genuinely pass-constant scalar fields such as the sun angular radius; do not make `uLightSpecular` static because clouds change it within the pass.

Two qualifications to v7:

- Moving derivative calculation inside pixel-divergent cascade/alpha branches is not a safe general shortcut. Use compile-time cascade elimination and preserve valid derivative evaluation across cascade boundaries
- [ShaderLoadD3D11](../CppProject/Asset/ShaderLoadD3D11.cpp) still rewrites loops to `[loop] while`; check converted code and compiled performance before claiming that constant quality bounds will be unrolled

Expected impact: shader execution and upload savings; potentially fewer draws when object-record capacity is the limiting factor. These shader changes alone do not remove a world traversal.

### P1: extend shadow caching to Standard with explicit invalidation

The existing cache is a useful foundation, but Standard sets its optimization flags to false in `render_start`. Its cascades rerender on every image. Realistic readiness is tied to sample resets through [render_update_samples](../GmProject/scripts/render_update_samples/render_update_samples.gml); simply enabling that flag for Standard can leave stale maps.

Cache each cascade by its final snapped light matrix, map size, shadow-relevant renderer settings and caster revision. Track geometry/transforms, visibility/hide/mode visibility, shadow participation, alpha textures and opacity, resource changes, wind, particles, placement and terrain edits. Changing only sunlight strength/color, PCSS quality or blur radius should not normally invalidate a Standard depth map when the projection and caster state are unchanged; the lighting result must still refresh.

Use the existing per-owner surface pools for separate viewport/camera contents. Reuse between owners only when the final projection, caster selection and required semantics match. Static/dynamic map splitting and staggered far-cascade updates are later options, not necessary for the first correct cache.

Expected impact: up to C fewer world traversals and their draws on a cache hit. For a two-cascade sun plus auxiliary data, 7 becomes 5. This is particularly valuable for repeated editor draws, light-color edits and camera movement within snapped cells; it is not a guaranteed saving on animated exports.

### P2: consolidate the remaining mask work and specialize auxiliary data

The old broad MRT recommendation is now too imprecise. The relevant remaining work is visible in [render_high_create_gbuffers](../GmProject/scripts/render_high_create_gbuffers/render_high_create_gbuffers.gml): three base traversals and an optional auxiliary traversal.

**New Standard-specific waste:** fog alone sets `render_auxiliary`, but that path allocates fog, SSS strength, SSS radius and glow surfaces, clears all four, and binds SSS outputs even though Standard does not run subsurface scattering. [shader_high_auxiliary](../GmProject/shaders/shader_high_auxiliary/shader_high_auxiliary.fsh) still decodes material data and calculates outputs beyond fog. A glow-enabled preset also requests the pass even if no visible object contributes glow.

Add explicit consumer flags and a small set of auxiliary variants: fog-only, fog/glow, and the Realistic/debug SSS outputs. Use visible contribution metadata to skip glow entirely when there is no producer. Avoid allocating/clearing unused attachments. When changing pooled surface formats or depth policies, also fix [surface_require](../GmProject/scripts/surface_require/surface_require.gml), which currently checks existence/size but does not recreate an existing surface for a changed descriptor.

To remove a world traversal, first target `SCENE_TEST` with a mask output alongside diffuse for normally blended geometry. Both currently use the same texture/vertex alpha discard logic, making this narrower consolidation more promising than a universal G-buffer rewrite. Initialize the mask separately from background/sun drawing, and write black for clouds and white for scene geometry. Then investigate fog output in an existing compatible pass. A C++-only extra attachment is an option; a compact layout or optional profile is preferable to always increasing MRT bandwidth. Keep a developer GM fallback if needed, but assess the product path on C++.

Preserve these existing semantics:

- `SCENE_TEST` uses [shader_replace_alpha](../GmProject/shaders/shader_replace_alpha/shader_replace_alpha.fsh), with texture/vertex alpha and the shared alpha-discard helper; preserve its blended coverage rather than replacing it with a binary nearest-depth flag
- Clouds write black mask values; objects and ground write white; background/sun and custom blends need their current behavior
- Fog depends on per-object participation and sky settings, not depth alone
- `only_render_glow` objects intentionally bypass ordinary visible geometry passes

Therefore neither diffuse alpha nor a blanket `depth < far` test is a drop-in scene-mask replacement. Custom object blend modes currently affect diffuse but not the mask pass, so a merged output needs independent blend behavior or a compatibility fallback for those objects. Removing both separate mask and fog-only traversals would save two world calls, but the saving is conditional on validated coverage/layout semantics.

### P2: deferred sunlight, then sampleable depth shadow maps

Deferred sunlight is still the largest structural way to remove the sun-lighting geometry replay: sample the G-buffers, reconstruct position, evaluate cascades and write diffuse/specular through a fullscreen pass. On a compatible scene this replaces one world traversal with a primitive draw. Cascades remain separate shadow renders.

However, v7 overstates the completeness of the current stored inputs. [shader_high_gbuffers](../GmProject/shaders/shader_high_gbuffers/shader_high_gbuffers.fsh) stores roughness, metallic, a view-dependent Fresnel term and SSAO in material RGBA. It does not retain base F0 or SSS strength/radius there. Standard still uses direct SSS translucency/highlights in its sunlight shader even though the separate scatter blur is Realistic-only. Its forward sunlight also derives metallic specular color from the raw base texture, while diffuse output can contain color adjustments and blended coverage.

Choose explicit compatible material/alpha classes or extend the data layout before replacing the forward shader. Preserve ordered transparent lighting and special-depth behavior. A single nearest-surface record cannot reproduce every layered forward result.

Do not treat direct additive rendering into final lighting targets as the low-risk standalone change proposed in v7. Current temporary light targets first resolve geometry under the current depth/alpha behavior, then add the resolved image. Adding every geometry fragment directly can retain contributions from overlapping layers that the temporary target would replace. It is much simpler to justify additive output after conversion to a fullscreen lighting pass.

Depth-only shadow resources remain worthwhile afterward or in parallel when GPU bandwidth is dominant. Current cascades use an R32F color map plus a separate D24S8 attachment in [FrameBuffer](../CppProject/Render/FrameBuffer.cpp); the depth shader samples alpha and writes color depth. A shader-readable hardware depth resource can remove duplicate storage/writes and enable an opaque caster path without color output. Preserve alpha-tested foliage, bias, projection conventions and receiver filtering. Hardware comparison filtering is not numerically identical to filtering the existing depth values before manual comparison, so this is a visual-validation change, not merely a format substitution.

## Additional new findings and smaller opportunities

### Skip zero-contribution lighting before building its work

[render_high_shadows](../GmProject/scripts/render_high_shadows/render_high_shadows.gml) sets `sunout` from sun color alone. A nonblack sun with zero sunlight strength still renders C depth maps and the complete sun-lighting pass, even though that shader multiplies its diffuse/specular contribution by the zero strength. Detect this case before cascade updates and remove C + 1 world calls.

Filter local lights for renderer visibility and zero contribution before both cache management and shadowless grouping. Currently shadowless point lights are added before the later `mode_visible[renderer_current]` check used for other lights. This is also a correctness gap: a point light disabled for Standard can enter its shadowless lighting group. Fixing collection semantics avoids unnecessary groups without inventing a new rendering algorithm.

### Deduplicate camera-texture renders across equivalent viewport requests

[view_update_surface](../GmProject/scripts/view_update_surface/view_update_surface.gml) invokes [app_update_cameras](../GmProject/scripts/app_update_cameras/app_update_cameras.gml) for each view. Required camera textures render again on each invocation; the old reuse block is commented out. Two same-renderer views can repeat the complete same camera render, including sunlight cascades.

Add a per-frame/revision completion key including camera, renderer/settings, dimensions, relevant effects and camera-texture dependencies. Reuse equivalent requests. Do not share Quick and Standard results or blindly skip intentional camera-feedback updates. This can remove several world calls at once in projects using cameras as textures, and a headless single-camera test will not reveal the duplicate viewport work.

### Use the default-material path before sampling the material map

In [common_material](../GmProject/shaders/common_material/common_material.fsh), `getMaterial()` fetches `uTextureMaterial` before testing whether `uMaterialFormat` is the no-map case, whose result does not use that fetch. Make the no-map path explicit before the texture read, or use a pass-wide no-map shader variant for eligible scenes. This applies to sunlight, G-buffers and auxiliary material evaluation.

The backend compiler might already move/eliminate some of this work, so inspect generated shaders and GPU timings before assigning a speedup. Avoid switching shader variants per object if that fragments a currently shared batch; use scene/pass-wide specialization or coherent branches first.

### Avoid regenerating Standard's identical PCSS kernel

[render_update_pcss_kernel](../GmProject/scripts/render_update_pcss_kernel/render_update_pcss_kernel.gml) caches by quality, but [render_high_update_jitter](../GmProject/scripts/render_high_update_jitter/render_high_update_jitter.gml) regenerates/rotates it again for sample zero on every Standard render. At sample zero the rotation angle is zero. Reuse the cached kernel directly for that path. This is a small converted-C++ CPU saving, not a draw-call optimization.

### Retain the useful engine recommendations, with corrected scope

- D3D still uploads full static/object constant buffers and binds/unbinds samplers/SRVs for each draw in `Shader::SubmitVertices`; add dirty state and resource-hazard-aware binding reuse after profiling
- OpenGL still repeats texture parameters and attribute setup; sampler/VAO caching helps submission cost, while a UBO batching fallback remains a high priority for the non-4.3 path
- Do not call C++ `gpu_get_*` a GPU synchronization bottleneck: the inspected getters read cached fields. The cost worth measuring is repeated lookups/state processing or actual flushes
- The earlier claim that initializing only D3D `RenderTarget[0]` necessarily leaves other MRT outputs unconfigured is incorrect when independent blending is disabled; the current blend descriptor uses shared state. A future mixed-blend MRT design does need explicit per-target behavior
- Ground deliberately uses standalone textures for correct filtering. Different pack pages, overflow pages, large custom textures and differing sampler states are legitimate batch boundaries. Do not undo those correctness decisions solely to approach one draw
- No-op shader/target transitions and cached fullscreen geometry remain useful, but they mainly reduce CPU/API overhead or primitive work rather than Standard's world traversal count

## Validation and implementation order

Use `RelWithDebInfo` C++ results as the performance baseline. Build/run only when requested. The following is a proposed validation plan, not an execution report.

1. Add pass/flush attribution and accurate per-output counter scopes; remove the unused frustum mesh and zero-contribution lights
2. Test cloud single-draw data passes; add allocation-free bounds and early rejection
3. Specialize cascade count/hard shadows and remove pass-constant surface UVs from object records
4. Add Standard cascade caching with revision tests
5. Specialize auxiliary outputs and consolidate mask/fog for compatible geometry
6. Prototype hybrid deferred sunlight and sampleable hardware shadow depth using the measured bottleneck to choose which comes first

For each stage, report CPU submission time, GPU pass time, total draws split into primitive/vertex/instanced, triangles, world calls, uploads and cache hits. A shader optimization can succeed with unchanged draw counts. A deferred pass can reduce vertex-buffer draws while adding a fullscreen primitive. A larger batch can lower draws while worsening culling and GPU time.

Test sunlight explicitly: override the dev_project preset with `shadows=true`, vary `shadows_sun_cascades` across the currently supported 1-3, and cover hard shadows plus quality 4/20/64, map sizes 1024/2048/4096, and suitable scene distances. The current split endpoints are 5%, 20% and 100% for one/two/three cascades over a distance capped at 7500. Hold effective shadow coverage comparable or report that quality/range difference; the old assumption that changing only cascade count keeps the same coverage is still false. `RENDER.md` currently says 1-5, but application and shader code clamp/use 1-3.

Use the existing feature sequence in dev_project to detect draw-count regressions, then add/choose representative Standard scenes for:

- Many small casters spread inside/outside cascades, one large scenery mesh, repeated scenery and dense clouds
- Opaque blocks, custom alpha, glow-only objects, resource pack changes and mip/filter combinations
- Animated wind, bending, moving casters, stationary casters with moving cameras, visibility changes, sun strength/color changes, and sun direction changes
- One/two viewports with identical and different cameras; camera textures; Standard/Realistic switches and resizing
- Direct SSS/backlighting and material maps, to catch deferred-lighting input losses
- Point/spot lights and 0/1/31/32 shadowless points, including lights hidden for Standard

Run D3D first and OpenGL afterward, including the non-SSBO fallback where supported. Compare output and shadow stability across cascade boundaries; keep the existing grass filtering, picker/placement depth and pack-page behavior. Use warm repeated measurements and separate first-use uploads/compilation from steady rendering. No expected percentage improvement is claimed without those product measurements.
