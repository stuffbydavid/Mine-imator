Prompt:

*Investigate performance optimizations for 3D rendering in CppProject only. The focus should be on improving the rendering speed of 3D scenes with many layered effects and accumulated samples. New proposed shader functionality or format changes should be compatible with both D3D11 and OpenGL 4.3-4.0/GLSL 1.50 modes, and on low-to-high end cards. Limit your improvement suggestions to changes outside the of Generated/ folder or existing shader files (treat them as read-only for this task), and do not consult any files outside of the CppProject directory.*

# 3D rendering performance investigation

## Scope and confidence

This is a static investigation of `CppProject` only. No file outside that directory was consulted. `Generated/`, existing `.vsh`/`.fsh` shader sources, and compiled `.d3d` shader blobs were not opened. The shader names listed by `Asset/index.qrc` were used only to establish that the packaged pipeline contains material, depth/normal, lighting, fog, bloom, depth-of-field, SSAO, subsurface, raytrace, reflection, and sample-add/unpack stages. No project build or executable run was performed.

Consequently, the report can identify costs in the C++ rendering abstraction with high confidence, but it cannot prove the exact pass order, which effects are inside the sample loop, or the measured share of CPU versus GPU time. The first recommendation is therefore lightweight pass-level instrumentation.

## Executive conclusion

The highest-value opportunities that remain entirely outside `Generated/` and existing shader files are:

1. **Restore geometry batching in the GLSL 1.50/OpenGL 4.0 path with a generated `std140` uniform block.** OpenGL currently disables all object batching unless the 4.3 SSBO probe succeeds (`Asset/ShaderLoadOpenGL.cpp:13-15`). This makes scene submission and draw count scale much worse on precisely the older/lower-end cards in scope.
2. **Add a backend-wide state/resource-binding cache and dirty uploads.** Every draw currently rebuilds temporary binding arrays, rebinds all textures/samplers, resubmits static data, and—in D3D11—unbinds all samplers and SRVs immediately after drawing (`Asset/Shader.cpp:639-739`). Layered full-screen passes magnify this overhead.
3. **Make repeated-sample geometry replay cheaper on the CPU.** Replace linear batch-cache searches with a hash key and replace allocation-heavy eight-corner frustum tests with center/extents plane tests (`Render/VertexBufferRenderer.cpp:61-69`, `Render/Bounds.cpp:14-25`, `Render/GraphicsApiHandler.cpp:725-745`).
4. **Create a cached full-screen draw path.** Every effect blit currently builds primitive vertices/indices and updates dynamic buffers through `draw_surface_ext` and `PrimitiveRenderer` (`Gml/DrawFunc.cpp:251-267`, `Render/PrimitiveRenderer.cpp:103-217`). A cached immutable triangle/quad for the common white, unrotated full-target blit avoids that work without altering shaders.
5. **Reduce render-target bandwidth only after measuring precision.** `hdr=true` currently means RGBA32F, or 16 bytes per pixel (`Render/FrameBuffer.cpp:45`, `Render/FrameBuffer.cpp:197`). RGBA16F intermediates would halve memory and bandwidth, but the actual accumulation target should remain RGBA32F until high-sample accuracy is validated.

The first four can preserve image results and existing shader inputs. Format changes are potentially the largest GPU win but are the only recommendation here with a direct numerical-accuracy risk.

## Why effects and accumulated samples stress this implementation

`Surface` is a texture-backed framebuffer, and effect passes change surfaces via `surface_set_target`, draw a surface through a shader, then change/reset the target (`Gml/RenderFunc.cpp:437-495`, `Gml/DrawFunc.cpp:251-273`). Each target switch flushes both primitive and vertex-buffer batching before rebinding the framebuffer. This is correct, but it means a layered stack is a sequence of hard batch boundaries.

RGBA32F bandwidth grows quickly:

| Resolution | One RGBA32F image | One simple read + write pass | RGBA16F read + write |
|---|---:|---:|---:|
| 1920×1080 | 31.6 MiB | 63.3 MiB | 31.6 MiB |
| 3840×2160 | 126.6 MiB | 253.1 MiB | 126.6 MiB |

These are lower bounds: multi-input effects, separable blur passes, MRT material passes, depth/normal data, cache misses, and clears add traffic. Any work inside an accumulation loop is then multiplied by the sample count. The resource list contains dedicated `shader_high_samples_add` and `shader_high_samples_unpack` stages (`Asset/index.qrc:192-195`), but determining what else is inside that loop would require the disallowed generated orchestration code or runtime profiling.

Geometry is also replayed per sample. D3D11 and OpenGL 4.3 can combine objects into cached meshes, but OpenGL below 4.3 explicitly turns batching off. Even where batching is active, each repeated batch scans `activeBatches` linearly to find an equal object-ID sequence, recomputes transformed bounds, and performs allocation-heavy culling.

## Recommended changes

### P0: Add asynchronous pass-level instrumentation

Add a small `RenderProfiler` in `Render/` and instrument framebuffer begin/end plus `Shader::SubmitVertices`. Label a pass with current shader name, target ID/size/format, attachment count, draw count, triangles, submitted constant bytes, texture/sampler binds, target switches, batch-cache probes/hits, and culled triangles.

For GPU time:

- D3D11: timestamp and timestamp-disjoint queries, collected several frames later.
- OpenGL 4.x: timer queries, also collected later. If the GLSL 1.50 mode runs on a context without timer-query support, retain CPU submission timing and counters.
- Never wait for a just-issued query; use a 3-4 frame query ring to avoid introducing a CPU/GPU synchronization point.

The existing counters exposed at `Gml/RenderFunc.cpp:638-670` cover only aggregate draw/triangle totals. They cannot attribute cost to a surface pass, resolution, upload, or state churn. Pass attribution is necessary to determine whether the dominant problem is repeated scene rendering, effect bandwidth, lighting/raytrace work, or CPU submission.

Useful benchmark axes are listed later. Instrumentation itself should be compiled out or nearly free when disabled.

### P0: Fix transient allocations and the matrix-array leak

`Shader::SubmitMat4Array` allocates `new float[arr.Size() * 16]` on its non-OpenGL-static path and never deletes it (`Asset/Shader.cpp:462-491`). On D3D11 this can leak on every matrix-array submission. Repeated light/bone/camera arrays could cause growing memory use and allocator pressure over a long render.

Use a reusable per-shader scratch vector/heap, write directly into it, and avoid an allocation per call. Apply the same scratch-storage approach to `SubmitFloatArray`, which currently allocates and frees for every call (`Asset/Shader.cpp:340-376`). Also replace per-draw temporary `QVector`s for D3D samplers, SRVs, and constant buffers (`Asset/Shader.cpp:641-643`, `Asset/Shader.cpp:703`) with fixed-capacity arrays whose active length is `numSamplers`.

This is low risk, backend-neutral at the API level, and worth doing before profiling long sample renders so a leak does not distort results.

### P1: Use UBO batching for OpenGL/GLSL 1.50 and 4.0

Current behavior:

- A vertex-format shader automatically enables batching when it contains normal input (`Asset/Shader.cpp:180-187`).
- D3D11 implements the per-object data as a constant buffer.
- OpenGL implements it as a GLSL 4.30 `std430` SSBO.
- If the GL 4.3 probe fails, `useBatching` is forced off (`Asset/ShaderLoadOpenGL.cpp:13-15`), even though the loader already has object-index rewriting and flat integer varyings (`Asset/ShaderLoadOpenGL.cpp:104-163`).

Implement a second generated storage backend using a GLSL 1.50 `std140` uniform block. Uniform buffer objects are available in the target OpenGL generation and avoid requiring SSBOs. Keep shader source files unchanged: this belongs in the same runtime source transformation that currently generates the SSBO and D3D cbuffer declarations.

Implementation details:

- Preserve the existing flat object index passed from vertex to fragment stages.
- Generate a `std140` array of per-object records and calculate CPU layout using `std140`, not the current `std430` assumptions.
- Query `GL_MAX_UNIFORM_BLOCK_SIZE`; choose `batchBufferMaxObjects = min(configured cap, limit / alignedObjectStride, MAX_BATCH_OBJECTS)`.
- If one record is unusually large, reduce batch size. If fewer than two records fit, fall back to direct drawing for that shader only.
- Use orphaning or a small rotating set of dynamic UBOs so the next batch does not overwrite storage still consumed by the GPU.
- Bind the same block to vertex and fragment stages. Keep the SSBO path as an optional OpenGL 4.3 variant, but benchmark it against UBOs; constant data can favor UBO hardware even on newer cards.
- D3D11 remains on its shader-model-4 cbuffer path, preserving feature-level 10/11 compatibility.

Expected effect: scenes with many objects should approach D3D11/GL4.3 draw-call behavior in the fallback mode, and accumulated samples no longer multiply one draw per object. The main risks are driver-specific dynamic indexing and layout errors, so validate on Intel, AMD, and NVIDIA using forced GLSL 1.50 and GL 4.0 modes.

### P1: Add a real state and resource-binding cache

The C++ layer tracks some logical state, but submission still performs redundant API work.

#### D3D11

`Shader::SubmitVertices` binds all samplers/SRVs, uploads buffers, binds both constant-buffer stages, sets layout/topology, draws, then clears every sampler and SRV slot (`Asset/Shader.cpp:688-739`). Samplers do not need to be cleared. SRVs need clearing only when a resource is about to become an RTV/DSV/UAV alias.

Recommended behavior:

- Track the SRV resource bound in each slot.
- Leave SRVs and sampler states bound after a draw.
- In `FrameBuffer::BeginUse` and MRT binding, clear only slots that alias the color texture being bound for output.
- Cache current shaders, input layout, topology, vertex/index buffers, constant buffers, render targets, viewport, rasterizer, depth, blend, sampler, and SRV state; issue API calls only on changes.
- Make `shader_set` return immediately when the requested shader is already current. It currently flushes, ends, begins, resets sampler state, and resubmits matrices even for the same object (`Gml/RenderFunc.cpp:335-348`, `Asset/Shader.cpp:212-260`).

This targets ping-pong effects particularly well: the source/target alias transition can be handled precisely instead of invalidating all slots after every full-screen draw.

#### OpenGL

Each draw activates and binds every texture, reapplies five texture parameters, and resets its sampler uniform (`Asset/Shader.cpp:644-684`). The `SamplerState::changed` flag is cleared but is not used to gate that work. Attribute arrays and pointers are also rebuilt every draw (`Render/Vertex.cpp:150-198`). Meshes bind and then release both buffers for every draw (`Render/Mesh.cpp:93-111`).

Recommended behavior:

- Track active texture unit and texture bound per unit globally.
- Apply wrap/filter/LOD only when that texture's effective sampler state changes.
- On OpenGL 4.0/4.3, prefer cached sampler objects; retain texture-parameter caching for the GLSL 1.50 fallback if its context lacks sampler objects.
- Set each sampler uniform once after program link unless its unit assignment changes.
- Cache VAOs per mesh/context, or at minimum cache the last VBO + vertex format in the existing per-widget VAO. A per-mesh VAO avoids repeating six enables/pointer descriptions for every sample draw.
- Do not unbind buffers merely to restore zero; later tracked binds establish the required state.

`BeginUse` should not clear complete CPU uniform buffers or forget every sampler binding unconditionally. Preserve per-shader values, keep explicit dirty bits, and rely on the global binding cache to establish actual API state after switching programs.

### P1: Hash batch reuse and make culling allocation-free

`VertexBufferRenderer::SubmitBatch` searches every active batch and performs an element-by-element object-ID comparison (`Render/VertexBufferRenderer.cpp:61-69`, `Render/VertexBufferRenderer.cpp:132-143`). In a sample loop, the first sample can populate the cache and every later sample repeats this search. As batch count grows, lookup approaches quadratic behavior per replay.

Build a stable 64-bit/128-bit key from:

- object/vertex-buffer ID sequence,
- object count,
- combined vertex/index counts,
- any future mesh revision/generation value.

Use a hash multimap from key to candidate batches, retaining the full comparison only for collision resolution. Keep the current active/inactive lifetime rules initially. Record lookup probes and hits in the profiler.

The culling path constructs a `QVector` of eight corners for each test (`Render/Bounds.cpp:14-25`) and tests up to 48 plane-point dot products (`Render/GraphicsApiHandler.cpp:725-745`). `AddBounds(transform)` also materializes corners (`Render/Bounds.cpp:52-59`). Replace both with center/extents math:

- Transform an AABB with `newCenter = M * center` and `newExtents = abs(M3x3) * extents`.
- Plane-test using `distance = dot(n, center) + d` and `radius = dot(abs(n), extents)`; reject when `distance + radius < 0`.

This is exact for affine transformed AABBs, removes heap activity, and reduces arithmetic. It benefits every backend and is multiplied by sample count.

After those no-image-change optimizations, evaluate **spatial batch splitting**. A 20,000-triangle combined batch (`Asset/VertexBuffer.hpp:10-12`) is culled as one union AABB. If objects are far apart, one visible object can force all combined geometry through every depth/material/shadow/sample pass. Add a configurable bounds-expansion or spatial-cell threshold when forming a batch, and tune it separately for integrated versus discrete GPUs. This trades draw count against rejected geometry and therefore must be profiler-driven.

### P2: Add a cached full-screen surface draw path

`draw_surface_ext` emits four transformed vertices per call (`Gml/DrawFunc.cpp:251-267`). `PrimitiveRenderer::SubmitBatch` then maps/copies dynamic vertex and index buffers, re-establishes culling state, and draws (`Render/PrimitiveRenderer.cpp:103-231`). Texture changes and shader/target changes naturally flush this batch, so a layered effect stack commonly pays this cost once per pass.

Add a fast path for the common case:

- white color,
- alpha 1,
- no rotation,
- full-target rectangle (including common downsample/upsample sizes),
- triangle-list/strip texture draw.

Cache immutable three-vertex full-screen triangles or four-vertex quads by rectangle size/UV orientation and backend context/device. Feed the same position/color/UV vertex contract expected by existing shaders, so no shader edit is needed. Use 16-bit indices or no index buffer for this tiny geometry if the surrounding draw path permits it.

Keep the existing `PrimitiveRenderer` fallback for tinting, arbitrary rotation, clipping semantics, unusual transforms, or shaders whose discovered attributes do not match the cached vertex format. Validate pixel-center and edge coverage on D3D11 and OpenGL; a quad is the conservative first implementation, while an oversized single triangle can be benchmarked later.

This primarily reduces CPU submission cost. It will not solve a fragment/bandwidth-bound 4K blur, but it prevents dozens or hundreds of effect passes and sample-add operations from repeatedly mapping tiny buffers.

### P2: Make uniform uploads dirty and split by update frequency

D3D11 calls `UpdateSubresource` for the full static buffer and full object buffer on every draw that owns them (`Asset/Shader.cpp:702-716`). OpenGL without batching calls `setUniformValue` immediately on each submission, even if the same effect parameter is submitted repeatedly (`Asset/Shader.cpp:279-460`). `BeginUse` clears whole CPU buffers (`Asset/Shader.cpp:241-256`), forcing repopulation after shader switches.

Add value caches and dirty ranges:

- For static uniforms, compare the incoming bytes with cached bytes and mark only changed ranges.
- Skip D3D static-buffer upload entirely when unchanged.
- Skip redundant OpenGL `glUniform` calls.
- Preserve values across program unbind/rebind; GPU uniform values already have program lifetime.
- Keep per-object inheritance behavior for batched data (`Shader::SubmitObject`) unchanged.

For the non-batched D3D path, separate high-frequency model/MVP and per-object values from pass/frame values such as V/P and effect parameters. Today `AddUniform` makes every value static whenever batching is disabled (`Asset/Shader.cpp:905-944`), which combines different update frequencies into one full-buffer upload. The loader can infer matrix frequency and retain the explicit `// Static` classification already parsed, without edits to existing shader files.

Profile `UpdateSubresource` versus dynamic-map/ring-buffer strategies on low-end drivers rather than assuming one is universally faster.

### P2: Implement the existing blend-enable API

`gpu_set_blendenable` is currently a no-op and comments that blending is always enabled (`Gml/RenderFunc.cpp:63-66`). D3D blend states created by `SetBlendingFuncs` always enable blending (`Render/GraphicsApiHandler.cpp:301-320`), while OpenGL is initialized with blending enabled (`Render/GraphicsApiHandler.cpp:411-415`).

Implement a cached blend-enabled state on both backends. Any existing caller that already requests disabled blending then receives the intended fast path without a generated-code change. Opaque geometry and overwrite-only full-screen passes can avoid destination reads/blend-unit work. Preserve the current default (`true`) and do not infer disablement merely from alpha values, because shader output and blend equations can make that unsafe.

Whether this yields a material win depends on calls hidden by the scope constraint; the profiler should count enabled versus disabled pixels/passes.

### P2: Consider instancing repeated vertex buffers

The current batching path creates combined GPU buffers by copying every source mesh and writing an object index into every copied vertex (`Render/VertexBufferRenderer.cpp:154-180`). This is reusable after creation, but it duplicates geometry and is unnecessary when many consecutive objects share the same `VertexBuffer`.

For runs of the same mesh, use `DrawIndexedInstanced` / `glDrawElementsInstanced`, with `SV_InstanceID` / `gl_InstanceID` selecting the per-object cbuffer/UBO record. Both are compatible with D3D11 shader model 4 and the OpenGL/GLSL generation in scope. The source transformation belongs in the C++ shader loader, so existing shader files stay untouched.

Restrict the first version to consecutive identical meshes so transparent ordering is preserved. Retain combined-mesh batching for heterogeneous runs. This is medium risk because the loader must provide a correct object-index variant for every backend.

### P3: Cache target/viewport transitions and remove tiny per-pass allocations

Every `surface_set_target` flushes, ends the previous framebuffer, and begins the requested one even if it is already current (`Gml/RenderFunc.cpp:481-491`). `FrameBuffer::BeginUse` always rebinds target and viewport (`Render/FrameBuffer.cpp:94-100`, `Render/FrameBuffer.cpp:226-246`). Cache the current framebuffer/MRT set and viewport, and short-circuit exact no-op transitions after preserving required clip/MRT semantics.

OpenGL MRT setup allocates a heap array of attachments on each call (`Render/GraphicsApiHandler.cpp:497-514`). Replace it with fixed/persistent storage. D3D blend-state lookup is a linear scan (`Render/GraphicsApiHandler.cpp:288-318`); key its four factors in a small hash/integer table, though this is likely less important once states are warm.

Add framebuffer resource pooling only if profiling shows frequent surface create/free or resize. `FrameBuffer::Update` already avoids reallocating for an unchanged size (`Render/FrameBuffer.cpp:25-29`, `Render/FrameBuffer.cpp:191-193`), so a pool provides little value if effect surfaces persist.

## Render-target format recommendation

The current `hdr` boolean maps directly to RGBA32F in both backends (`Render/FrameBuffer.cpp:45`, `Render/FrameBuffer.cpp:197`). Introduce an internal enum such as `RGBA8`, `RGBA16F`, and `RGBA32F`, while keeping the existing boolean constructor behavior as a compatibility mapping until results are known.

Recommended policy after profiling and image validation:

- **Accumulation/history/sample sum:** RGBA32F initially. High sample counts can lose low-order contributions in RGBA16F, especially when storing an unnormalized sum.
- **Lighting/effect intermediates:** test RGBA16F. Bloom, fog, DoF, indirect blur, and similar intermediates usually gain substantially from halved traffic and footprint.
- **Masks/CoC/AO/single-channel data:** compact formats could save more, but selecting them changes render-target output shape and therefore would require shader or orchestration work excluded from this task.
- **Final LDR/UI:** explicit RGBA8 rather than an unsized OpenGL internal format.

Within the present scope, there is no reliable way to identify every surface's semantic role: the C++ API receives only `depthBuffer` and `hdr` booleans (`Gml/RenderFunc.cpp:364-372`). Do not silently convert all HDR surfaces to RGBA16F. That could speed effects while corrupting high-sample accumulation. A scoped experiment may expose a runtime format policy for testing, but production adoption needs a role signal from an allowed non-generated call site; otherwise defer it.

Required validation for any half-float experiment:

- samples 1, 8, 32, 128, and the application's practical maximum;
- very bright emissive lights, nearly black indirect light, fog, transparency, bloom, and DoF together;
- NaN/Inf checks and maximum/mean image error against RGBA32F;
- integrated GPUs as well as high-end discrete cards, because reduced footprint can change tiling/residency behavior substantially.

## Ideas intentionally not recommended under this scope

- **Move effects outside the sample loop:** potentially very high value, but exact pass ordering is in the disallowed orchestration code. Instrument first and change only when that code is in scope.
- **Replace sample-add ping-pong with additive hardware blending:** could remove a previous-accumulation texture read, but it changes accumulation shader/output semantics and pass setup. It is not safe without examining/modifying excluded code.
- **Fuse blur, lighting, fog, bloom, or resolve passes:** requires shader edits and careful dependency analysis.
- **Dynamic-resolution or half-resolution effects:** requires surface sizing and sampling decisions in the effect pipeline, not just the C++ backend.
- **Compute-shader rewrites:** not available in GLSL 1.50 and would violate the compatibility requirement.
- **D3D-only deferred contexts/command lists:** no equivalent benefit path for required OpenGL modes and often driver-sensitive for this workload.

## Compatibility matrix

| Proposal | D3D11 FL10/11 | OpenGL 4.3 | OpenGL 4.0 | GLSL 1.50 fallback | Low-end suitability |
|---|---|---|---|---|---|
| Pass profiler/counters | Yes | Yes | Yes | CPU counters; timer query if exposed | Yes, disabled by default |
| Allocation/leak fixes | Yes | Yes | Yes | Yes | Strong |
| `std140` UBO batching | Existing cbuffer retained | Yes | Yes | Yes | Strong; capacity queried |
| Binding/state cache | Yes | Yes | Yes | Yes | Strong |
| Hash batch cache + AABB culling | Yes | Yes | Yes | Yes | Strong |
| Cached full-screen geometry | Yes | Yes | Yes | Yes | Strong |
| Dirty uniform uploads | Yes | Yes | Yes | Yes | Strong |
| Real blend disable | Yes | Yes | Yes | Yes | Strong |
| Repeated-mesh instancing | Yes | Yes | Yes | Yes | Validate drivers |
| RGBA16F intermediates | Yes | Yes | Yes | Yes on target hardware | Strong if precision passes |
| Compute-based effects | No for stated baseline | Optional only | No | No | Reject as common path |

No recommendation requires editing an existing shader file. The UBO and instancing variants extend the existing runtime shader translation in `Asset/ShaderLoadOpenGL.cpp` / `Asset/ShaderLoadD3D11.cpp`; generated GLSL/HLSL must remain within GLSL 1.50 and shader-model-4 capabilities respectively.

## Benchmark and acceptance plan

Run each case on D3D11 feature-level 10/11 and forced GL 4.3, GL 4.0, and GLSL 1.50 paths:

1. 1080p and 4K, samples 1/8/32/128.
2. Minimal effects versus the largest supported layered stack.
3. Many unique objects, many repeated instances, and a scene where most objects are outside the frustum.
4. Static camera versus sample-jittered camera; static transforms versus animated transforms.
5. Integrated/low-end, midrange, and high-end cards from multiple vendors.

Capture:

- total CPU render-submission time and total GPU time;
- per-pass GPU time and estimated bytes/pixels;
- draw calls, triangles submitted, triangles rejected by culling;
- shader/program switches, framebuffer switches, texture/sampler binds;
- constant/SSBO/UBO upload calls and bytes;
- batch-cache probes/hits and combined-batch build bytes;
- process memory over a long high-sample render.

Acceptance criteria:

- Bit-identical output for state caching, batch hashing, culling math, allocation fixes, and cached quad path (allow only an explicitly justified edge-rasterization tolerance for a triangle variant).
- No D3D hazard/debug-layer warnings and no GL errors in debug validation.
- No draw-order changes for alpha/transparency.
- GLSL 1.50/GL4.0 batching falls back cleanly when uniform-block limits are too small.
- Format changes meet an agreed numerical/image error threshold at the maximum sample count.

## Suggested implementation order

1. Add pass/counter profiling and fix `SubmitMat4Array`/scratch allocations.
2. Add binding/state caching, same-shader short-circuiting, and dirty uniform uploads.
3. Replace batch linear search and current culling math; measure CPU scaling with samples.
4. Add GLSL 1.50/GL4.0 UBO batching; compare directly with GL4.3 SSBO and D3D cbuffer results.
5. Add the cached full-screen path and per-mesh/context VAOs.
6. Profile spatial batch splitting and repeated-mesh instancing.
7. Trial RGBA16F intermediates only with precision-aware surface roles and image validation.

This order starts with low-risk, result-preserving changes, directly addresses the severe OpenGL fallback asymmetry, and leaves numerical/render-pipeline changes until measurements show they are needed.
