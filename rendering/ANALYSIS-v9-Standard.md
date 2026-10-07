# Standard sunlight optimization review — v9

## Scope and conclusion

Reviewed [v8](ANALYSIS-v8-Standard.md) against the current working tree on 2026-10-07, including the staged CPU/GPU changes and the latest timeline helper edits. This is a source review, not a new benchmark report. No build or application run was performed. Performance acceptance must use the optimized C++ product, not the GameMaker VM.

Shadow/result caching and new cross-frame caches are outside this review. Existing prepared matrices, mesh metadata and binding shortcuts are listed when documenting completed work, but extending caching is not a proposed next step.

**The main pass-consolidation work proposed in v8 is now implemented.** An eligible Standard sunlight scene needs one combined scene traversal plus one traversal per cascade. The next important work is rejecting irrelevant casters sooner, making the remaining cascade traversals cheaper, and reducing C++ upload and shader work. Another fullscreen sunlight implementation would not remove a traversal from this already-combined path.

## Current traversal budget

The decision points are in [render_high](../GmProject/scripts/render_high/render_high.gml), [render_high_create_gbuffers](../GmProject/scripts/render_high_create_gbuffers/render_high_create_gbuffers.gml) and [render_high_shadows](../GmProject/scripts/render_high_shadows/render_high_shadows.gml).

For combined output, no local lights, no camera-texture renders and no editor selection/placement overlays:

| Standard path | World traversals, with C sun cascades |
| --- | ---: |
| Full combination: COLOR + mask + fog + G-buffers + sunlight | C + 1 |
| Glint present, otherwise eligible: COLOR/mask/fog and G-buffers/sunlight | C + 2 |
| Glow requires auxiliary output: COLOR/mask, G-buffers/sunlight, auxiliary | C + 3 |
| Sun combination unavailable, but mask/fog combination works | C + 3 |
| Separate mask, auxiliary and sunlight fallback | C + 5, when auxiliary is needed |

Thus the fully combined one/two/three-cascade paths use **2/3/4 world calls**, not v8's 6/7/8. Standard does not automatically qualify for the full combination: build mode, graphics support, camera range, visible glow/glint and requested debug outputs can change the path. D3D and supported GL 4.3 use the C++ combinations; GameMaker and the older GL fallback retain additional traversals.

Each shadowed point light still adds six face traversals and one lighting traversal; a shadowed spot adds two. Shadowless spots add one each, and shadowless point lights are grouped in batches of up to 31. SSAO, DOF and ordinary post-processing do not add a world traversal. Clouds can require two mesh draws inside a single traversal; this is not two `render_world()` calls.

These counts describe scene walks, not API draws. Batching can merge many mesh submissions, while texture pages, filtering, culling, blending, target changes and capacity limits can split a traversal into several draws.

## Disposition of v8 suggestions

“Implemented” means the current source contains the change, including uncommitted work. It does not claim a newly measured speedup.

| Suggestion | Status and current evidence |
| --- | --- |
| Reject an invisible aggregate before looking up/building combined meshes | Implemented: [VertexBufferRenderer::SubmitBatch](../CppProject/Render/VertexBufferRenderer.cpp) checks aggregate visibility before searching `activeBatches` or calling `CreateBuffers` |
| Replace allocating corner transforms/tests | Implemented: [Bounds](../CppProject/Render/Bounds.cpp) uses affine center/extents; [IsVisible](../CppProject/Render/GraphicsApiHandler.cpp) tests the positive AABB vertex against each plane |
| Avoid rebuilding the same bounds twice for instancing | Implemented: `Add` constructs world bounds once and merges those bounds into the batch |
| Reject ordinary small casters before batching and GML setup | Not implemented: only the large single-mesh instancing path rejects individual objects before append |
| Remove unused `cam_frustum` mesh generation | Implemented: the unused build/build-vbuffer calls are absent from [render_update_cascades](../GmProject/scripts/render_update_cascades/render_update_cascades.gml) |
| Separate 1/2/3-cascade sunlight shaders | **Tried and discarded** after limited measured benefit, per the development decision; the current common shader still declares three cascades. Do not reopen this as a high-priority recommendation |
| Hard-shadow specialization and smaller approximate PCSS kernels | Separate variants are not present; the existing runtime hard-shadow branch remains. Approximate sample reductions are not an exact optimization |
| Remove pass-wide sunlight UV rectangles from object records | Implemented: sun samplers have `pass_uv`; [Shader::LoadCodeCommon](../CppProject/Asset/Shader.cpp) keeps them out of per-object records. This removes three vec4 fields, 48 logical bytes before record alignment |
| Make small exact PCSS reductions | Implemented in [common_sun](../GmProject/shaders/common_sun/common_sun.fsh): skip the center fetch unless hard shadows or backlit SSS need it, and calculate gradient length once. Blocker-free early exit remains |
| Reuse Standard's unchanged PCSS sample kernel | Implemented: [render_high_update_jitter](../GmProject/scripts/render_high_update_jitter/render_high_update_jitter.gml) uses the existing kernel for sample zero rather than generating/rotating another |
| Consolidate scene mask and fog-only auxiliary work | Implemented through C++ independent MRT blending. `SCENE_TEST` and the fog-only auxiliary replay are skipped when eligible |
| Match auxiliary outputs to actual consumers | Implemented: Standard uses [shader_high_auxiliary_standard](../GmProject/shaders/shader_high_auxiliary_standard/shader_high_auxiliary_standard.fsh); SSS/radius/glow attachments are conditional. Visible glow/glint checks are performed in [render_start](../GmProject/scripts/render_start/render_start.gml) |
| Remove the sunlight receiver geometry replay | Implemented without a deferred rewrite: sunlight is evaluated while writing G-buffers, and the full Standard combination also folds those outputs into COLOR |
| Write sunlight directly into final lighting targets | Implemented when glint is absent; local lights and glint retain temporary targets. The combined temporary-copy path no longer multiplies its alpha a second time |
| Use shader-readable depth-only sunlight targets | Implemented on C++: [FrameBuffer](../CppProject/Render/FrameBuffer.cpp) creates shader-readable D32 depth resources on D3D and DEPTH_COMPONENT32F on GL. [shader_depth_ortho](../GmProject/shaders/shader_depth_ortho/shader_depth_ortho.fsh) has no C++ color output; GM retains color depth. Point/spot and scene/DOF depth have not been converted by this work |
| Avoid default material-map reads | Implemented: [getMaterial](../GmProject/shaders/common_material/common_material.fsh) samples only the mapped-material branches; missing material/normal channels use explicit absence flags/zero textures |
| Genuine no-normal-map fast path | Implemented in [common_gbuffers](../GmProject/shaders/common_gbuffers/common_gbuffers.fsh): ordinary unmapped surfaces bypass both TBN constructions and normal transformation. Procedural water and normal-mapped materials retain the full path |
| Remove non-depth setup from cascade renders | Implemented with separate timeline/block/item depth helpers. Glint, material/normal setup and ordinary blend/color processing are bypassed where not needed |
| Reduce model-part setup repeated across passes | Implemented: resolve the winning diffuse texture before binding, omit per-shape matrix resets, use prepared shape matrices/mesh IDs/hidden flags, and replace the armor-name condition chain with a startup map |
| Finish low-level uniform/sampler lookup removal | Implemented: enum-indexed GML handles, a contiguous C++ `QVector` of uniforms, fixed sampler UV-index arrays and a precomputed `forceTexScale` flag |
| Make transparent-block sweeps conditional and cheap | Implemented: depth-sign boundaries, resource mesh-presence flags, prepared timeline eligibility and the viewport `render_particles` guard. [tl_update_block_render](../GmProject/scripts/tl_update_block_render/tl_update_block_render.gml) now lets `tl_get_block_res` include block-format models and particle types rather than excluding them |
| One cloud draw in overwrite-compatible data passes | Implemented selectively in [render_world_sky_clouds](../GmProject/scripts/render_world_sky_clouds/render_world_sky_clouds.gml). The combined color/sunlight paths still need the coverage/depth behavior of the two-draw path |
| Avoid unused attachments and redundant final copies | Partly implemented: many data/lighting/post-process targets omit depth, fog joins Standard lighting, and direct sunlight removes two fullscreen copies. The final composite/effect pipeline still has fullscreen work |
| Skip zero-contribution sun/local lights | Still outstanding: sunlight eligibility tests color, not strength; shadowless-point collection still precedes renderer-mode visibility filtering |
| Detailed per-pass GPU timing and flush attribution | Still outstanding: existing totals do not explain per-cascade GPU cost, upload volume or individual batch-flush reasons |
| Deferred local lights / direct point-atlas rendering | Still outstanding, but secondary for sun-only Standard scenes |
| Standard shadow caching / equivalent camera-texture reuse | Excluded from the next-work list at the user's request |

The previously implemented surface pooling, compact buffer formats, blur pyramids, DOF depth reuse, glow-source reuse, scratch storage, pack-local texture pages and large-mesh instancing remain relevant. There is no reason to redo these as general batching changes. Sample accumulation and converged Realistic output are not priorities for Standard.

## Crucial work remaining, without new caching

### P1: reject irrelevant sunlight casters before expensive setup

`VertexBufferRenderer::Add` still appends ordinary small meshes even when their bounds are completely outside the cascade. An aggregate can intersect the cascade while containing many individually irrelevant objects. Aggregate rejection helps only when the entire batch is outside.

Start with conservative per-mesh rejection for sun-depth mode before append, using the already calculated world bounds. Then move a coarse rejection earlier in the timeline depth path so completely irrelevant timelines avoid resource, texture and shape setup. Keep surviving objects in their existing order and compatible batches; do not introduce one batch per object or mandatory spatial cells.

This requires deformation-safe bounds. Wind, bent shapes, camera-facing shapes and particles can exceed undeformed mesh bounds; use a conservative envelope or bypass early rejection for those cases. Test the **light's caster volume**, not the view camera frustum: off-screen objects can cast visible shadows. Whole-resource scenery rejection is useful, but large scenery spanning the cascade will eventually need conservative submesh bounds to benefit further.

Expected benefit: fewer caster vertices/fragments and less CPU submission per cascade. World-call count stays C + 1; draw count falls only when batches disappear or become cheaper to submit. Visibility-dependent mesh sequences can increase combined-mesh construction work, so measure that tradeoff before expanding the scope.

### P1: avoid the second transparent-block timeline walk in sun-depth passes

[render_world_list](../GmProject/scripts/render_world_list/render_world_list.gml) still builds and replays transparent-block candidate lists for each cascade. The ordinary camera-color pass needs that ordering; a sun-depth pass writes depth, not blended scene color.

Investigate a sun-depth-only single walk that submits both opaque and eligible alpha-tested/hashed block groups from each timeline. [render_world_block_depth](../GmProject/scripts/render_world_block_depth/render_world_block_depth.gml) already supports the neutral `render_world_block_transparent = null` mode that does not stop after opaque groups. This also avoids setting up the same mixed scenery or spawner twice per cascade.

Keep the camera pass unchanged. Preserve shadow participation, alpha discard/hash, particle handling, special timeline depth order, water exclusion and equal-depth results. Do not globally eliminate the transparent sweep or change its texture-filtering policy for visible color rendering.

Expected benefit: fewer CPU list walks, redundant timeline/uniform/texture checks and pass-local state transitions. This does **not** remove a `render_world()` call; it simplifies work inside each cascade traversal.

### P1: give genuinely opaque casters a cheaper depth shader path

The new depth-only target removes color storage and writes, but `shader_depth_ortho` still samples diffuse alpha and executes the discard helper for every caster fragment. Dense opaque terrain can therefore remain texture/fragment-bound.

Add a conservative opaque-caster classification based on the effective texture and mesh alpha, not just `DEPTH0` or object opacity. Custom pack textures, vertex/shape alpha, animated textures and hashed transparency can invalidate an opaque assumption. Unknown cases must retain the current shader.

Start with a coherent per-object opaque flag that bypasses the alpha fetch/discard, or a pass-wide opaque path where applicable. A no-pixel-shader opaque path is a later option; switching shaders for each object can fragment batches and erase the benefit. Keep cutout foliage and partial-alpha casters on the existing path.

Expected benefit: lower GPU fragment and texture cost across every cascade, with unchanged shadow coverage. It complements D32 depth-only storage; it is not already accomplished by removing the color output.

### P1/P2: reduce actual C++ upload work, not just uniform-name lookup

[Shader::SubmitVertices](../CppProject/Asset/Shader.cpp) still uploads the full allocated D3D object constant buffer for each draw, even for a small populated prefix. It also processes and binds the sampler/SRV arrays and then unbinds them after each draw. The current GL SSBO path uploads the used object prefix instead.

The next non-caching experiment should reduce object upload volume with appropriately sized/streamed buffers. Do not merely add another GML uniform shortcut: name/index lookup has already been addressed. Preserve object-index layout, buffer alignment and shader capacity, and use a valid D3D constant-buffer update strategy rather than assuming arbitrary partial `UpdateSubresource` writes are supported.

Measure bytes per draw and CPU time first. Small model-part batches are the likely beneficiary; a capacity-full terrain batch may gain little. Reworking sampler/VAO/binding reuse would introduce additional state caching and is intentionally deferred here.

### P2: simplify the standalone sun-depth sampling helper

`pass_uv` removes per-object rectangles, but the generated `_sampleUvRect` still computes atlas transforms, repeat handling and derivatives for every PCSS depth fetch. Sun targets are standalone single-mip textures with pass-wide rectangles, so this is a narrower shader opportunity than cascade-count variants.

Prototype a dedicated depth-target sampling helper that preserves UV orientation, edge behavior and the existing filter semantics. Explicit level-zero sampling could remove derivative work, but is **not automatically equivalent**: the current D3D sampler uses different minification/magnification filters, while GL configuration differs. Do not replace `SampleGrad`/`textureGrad` blindly or switch to hardware comparison filtering and call it an exact optimization.

At quality 20, the ordinary soft-shadow path now makes ten blocker reads and up to twenty filter reads; a center read is additionally needed for the backlit SSS case. With no blockers, the twenty filter reads are skipped. Preserve these reductions and the current kernel/quality before proposing approximate sample-count changes.

### Low-risk cleanup: zero-contribution lights and cascade setup

Check sunlight strength as well as color before constructing unused depth maps. Avoid losing the combined COLOR/G-buffer path just because sunlight contributes zero: turning off `render_sun_combined` alone can bring back a separate G-buffer traversal. The useful result is no unused cascade work while retaining compatible scene-output consolidation.

Filter local lights for renderer visibility and zero strength before shadowless grouping. Besides wasting work, the current early shadowless-point insertion can include a light disabled for Standard.

In [render_update_cascades](../GmProject/scripts/render_update_cascades/render_update_cascades.gml), the same `sunmatv` inverse is calculated inside the cascade loop. Move that invariant inverse outside the loop; similarly hoist fixed bias data and other truly invariant setup. These are small CPU savings, not a substitute for reducing caster or PCSS work.

## What is no longer a priority

- Do not repeat the discarded 1/2/3-cascade shader experiment or propose a large hard/soft/quality variant matrix without new evidence
- Do not replace the combined sunlight path with a fullscreen receiver pass merely to remove `HIGH_LIGHT_SUN`: that replay is already absent in typical eligible scenes
- Do not reduce cascade coverage, map resolution, shadow quality or cloud coverage to claim an optimization with identical output
- Do not remove the scene mask, fog participation, direct SSS or the ordered transparent camera path: the current combinations preserve consumers that a nearest-depth-only replacement would lose
- Do not undo standalone ground textures or legitimate pack/filter batch boundaries solely to lower vertex-submit counts
- Do not add Standard shadow caching or cross-viewport result reuse in this phase

## Measurement and proposed acceptance order

1. Add per-pass GPU timing and counters for candidate/rejected meshes, triangles, populated/uploaded object bytes, combined-mesh construction and batch-flush reasons
2. Test conservative sun-depth caster rejection, then the single-walk block-depth path
3. Test the opaque depth fast path and smaller C++ object uploads independently
4. Test specialized standalone depth sampling only with matching filtering/output; keep cascade variants discarded
5. Finish zero-contribution light filtering and invariant cascade setup

Use warm RelWithDebInfo C++ measurements. Report CPU submission, GPU cascade/receiver time, Render_ms, Surface_ms, world calls and actual primitive/vertex draws separately. Existing aggregate CPU timings are not GPU timestamps, and PNG/readback time must not be credited as shader speedup. No percentage gain is asserted by this review.

For future requested validation, start with D3D Standard `dev_project` and `dev_project_steves` frame 0 for correctness, then the existing feature sequence and representative moving casters. Include dense opaque scenery, leaves/cutouts, custom alpha, wind/bending, block-model particles, direct SSS, glint/glow fallbacks and one/two viewports. Check GL after D3D, including the non-4.3 fallback where supported.

Compare actual covered shadow distance when testing different cascade counts. The current endpoints still end at 5%/20%/100% for one/two/three cascades over the capped range; the current source does not provide equal full-range coverage for those configurations. Changing that is a visual/settings-policy decision, not a performance-only optimization.
