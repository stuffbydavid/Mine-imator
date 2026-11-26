# Playback performance optimization review — v10

## Scope and conclusion

Reviewed the timeline playback path, GML orchestration, generated C++ behavior, and handwritten renderer on 2026-10-23. This report covers continuous playback, scrubbing, and frame-time stability, with export treated as a separate workload. It proposes changes and acceptance checks; it is not a benchmark report. No build or application run was performed for this document.

**Start by reducing repeated per-timeline channel evaluation, unnecessary property updates, and matrix-cache churn.** Follow with native transform work and more selective bend updates. Retained topology and GPU bending are separate experiments whose CPU savings must be weighed against GPU bandwidth, memory, and repeated shader work.

Judge acceptance using the optimized **C++ product** on DirectX and OpenGL. GML changes matter because their converted code controls the application; GameMaker VM timings should not determine priority. Proposal IDs stay stable so each change can be introduced and benchmarked separately. Potential benefits overlap and cannot be added together.

## Current playback work

The main update sequence is in [app_update_animate](../GmProject/scripts/app_update_animate/app_update_animate.gml), [tl_update_values](../GmProject/scripts/tl_update_values/tl_update_values.gml), and [tl_update_matrix](../GmProject/scripts/tl_update_matrix/tl_update_matrix.gml). The matrix routine is named `tl_update_matrix`, not `app_update_matrix`.

| Area | Work to isolate | What increases its cost |
| --- | --- | --- |
| Animation evaluation | Keyframe selection, value-array copies, easing, enabled-channel visits | Timeline count, keyframe count, and enabled channels |
| Transforms and inheritance | Local/world matrix construction, ancestor walks, child propagation | Dirty timelines, hierarchy depth, and inheritance settings |
| Bend and geometry updates | Deformation, mesh generation, normals, tangents, bounds, resource creation | Changed bends, tessellation, alpha topology, and actual rebuilds |
| Render preparation/submission | Shape metadata, world matrices, sorting, batch lookup, state/upload work | Visible shapes, render passes, batch fragmentation, and sorted objects |
| Editor and other views | Timeline/UI drawing, previews, particles, gizmos, additional viewports | Editor state, visible previews, and extra views |
| Synchronization and maintenance | GPU waits, picking/readback, periodic cleanup, asset lifetime | Active consumers, resource churn, and session duration |

Compare the same scene paused and playing in uncached Quick mode first. A fast paused viewport alone does not isolate the GPU or identify the CPU routine responsible for a playback slowdown. Count actual mesh generations rather than assuming every bend-update call regenerates geometry.

Changes belong in GML, handwritten C++, or CppGen. Generated C++ is useful evidence for copies, conversions, scopes, and native calls, but is overwritten by regeneration.

## Recommended priorities

| Proposal | Aim | Workload to measure |
| --- | --- | --- |
| P17 | Batch channel checks and retain shape-cache storage | Hundreds of animated timelines with mostly constant channels |
| P01 | Remove unnecessary owning array copies | Keyframe evaluation, biome blending, and path sampling |
| P02 | Update only affected property categories; improve keyframe search | Mixed animation and deep hierarchies |
| P07 | Keep transform calculations native | Many transforming timelines |
| P18 | Separate bend and rigid updates; reuse and batch matrix work | Bend-only animation, moving parents, and many model shapes |
| P04 | Retain bend topology/buffers; evaluate GPU deformation | Continuous bending of blocks and planes |
| P03 | Reduce bend-script generation costs | Detailed bent or extruded geometry |
| P05 | Prepare rendering once and reject irrelevant work earlier | Large scenes and multiple render passes |
| P08 | Improve batch reuse and render-state submission | Many small shapes and state changes |
| P15 | Reduce editor, preview, and additional-view work | Editor playback slower than headless evaluation |
| P11 | Replace quadratic depth sorting | Many transparent/custom-depth timelines |
| P06 | Restrict IK/path/pose work to dependencies | Rigs, moving targets, and path followers |
| P09 | Reuse scenery-copy setup | Large repeated scenery ranges |
| P10 | Reduce particle simulation and attraction costs | Many particles, missed steps, or path attractors |
| P14 | Reduce maintenance and lifetime churn | Playback hitches and long sessions |
| P13 | Reduce picking readback and synchronization | Playback with active picking or build-mode interaction |
| P12 | Generate geometry only after the final required pose | Proven intermediate mesh rebuilds |
| P16 | Pipeline export readback and encoding | Export throughput; a separate measurement from playback |

Promote workload-specific proposals when profiling supports them. Preserve all renderers and visual behavior while comparing performance. Disabling sorting, reducing geometry, or changing simulation quality is not an equivalent optimization baseline.

## Optimization proposals

### P01: Remove unnecessary owning array copies

read a few values without copying their complete containers on every update.

Read selected keyframe values directly instead of copying complete value arrays into each timeline. Apply the same approach to environment/biome interpolation. Borrow a spline's point table for one native sampling call and read only the neighboring samples; provide bounded const-reference array access where useful. Keep intentional endpoint/result copies independent of their inputs.

Inspect generated signatures and generic dispatch too: an apparently read-only GML argument may cross a by-value `ArrType` boundary. Do not retain borrowed references across array mutation, keyframe edits, object destruction, or subsequent frames. Retain custom-biome caching by the relevant biome/keyframe inputs.

Measure copied bytes and allocations alongside animation time. Compare forward/reverse/seamless playback, seeks, keyframe edits, custom biomes, open/closed paths, endpoint extrapolation, and independence of returned samples.

Sources: [animation](../GmProject/scripts/tl_update_values/tl_update_values.gml), [evaluator](../GmProject/scripts/tl_update_values_ease/tl_update_values_ease.gml), [spline sampling](../GmProject/scripts/spline_get_point/spline_get_point.gml), [biome colors](../GmProject/scripts/res_update_colors/res_update_colors.gml), [array storage](../CppProject/Type/ArrType.cpp).

### P02: Update only affected animation and inherited properties

prevent an unrelated property change from requesting complete transform and inheritance work.

Accumulate separate local, transform, scale, bend, and appearance dirty categories. Position/rotation changes should avoid unrelated scale/material walks; appearance changes should retain transforms. Local light, camera projection/effect, environment, sound, text, and particle parameters should not propagate unnecessary transform work. Retain conservative full invalidations for structural edits and existing IK/path/pose callers.

Propagate categories in parent-before-child order. Preserve inherited pose bending between transform evaluations and use exact change checks. Handle a hidden part becoming visible and texture changes that require refreshed geometry or shape metadata.

Replace scanning from the first keyframe with a fresh binary upper-bound search over ordered positions. Preserve endpoints, duplicate-position ordering, and the subsequent seamless-loop adjustment. Persistent interval cursors are a separate option requiring invalidation after edits, seeks, reverse playback, or loop changes.

Do not substitute a parent's effective material for the raw ancestor walk without proving equivalence. Inheritance stop flags, intermediate clamping, texture precedence, and multiplication order matter. Do not prune descendant categories solely because a parent's final value appears unchanged.

Measure timelines visited versus updated and ancestor walks per category. Compare nested hierarchies, inheritance switches, tiny bend changes, texture/visibility edits, IK/path/pose rigs, duplicate keyframes, audio/particle events, and seamless loops.

Sources: [value updates](../GmProject/scripts/tl_update_values_ease/tl_update_values_ease.gml), [matrix/inheritance updates](../GmProject/scripts/tl_update_matrix/tl_update_matrix.gml), [keyframe progress](../GmProject/scripts/tl_update_values_progress/tl_update_values_progress.gml).

### P03: Reduce bending-script generation costs

make necessary topology generation and CPU deformation cheaper without changing the mesh.

For blocks and flat planes, keep bend arguments and intermediates native where possible. Prepare corner-offset vectors/differences once, interpolate components without temporary dynamic-vector arguments, reuse normal bases and unbent matrices, share X/Y easing factors, and prepare the pinching axis/factor once. Remove calculations whose outputs are replaced by sharp-segment or offset-normal branches.

Keep the generators' different behavior: block starts use their original easing, sharp block segments use their required angle behavior, flat-plane segments retain their easing and disabled segment pinching, and extruded-plane sharp weights retain their snapping. Preserve angle limits, segmentation boundaries, anti-Z-fighting scale, corner offsets, UVs, mirroring, fractional dimensions, winding, and emission order.

Additional opportunities:

- Prepare extruded-plane coordinate sequences and bend matrices once per inner coordinate, rather than once for every outer/inner grid pair. A 16-by-16 grid can require 17 distinct coordinate matrices instead of 289 constructions; that is an operation-count example, not a frame-speedup estimate.
- Hoist shape-invariant UV, pivot, rotation, segmentation, and offset data, with invalidation for changed shapes, textures, scale, or bend settings.
- Establish a normal contract across generators, triangle emission, and native packing. Remove discarded work and redundant normalization only after comparing packed attributes.
- Resolve the native builder once, use typed lattice/scratch storage, borrow alpha grids, and emit complete vertices. Retain recent-vertex deduplication, seams, wave flags, and tangent behavior.
- Prepare sparse alpha topology: occupied cells, exposed faces, UVs, and referenced lattice vertices. Alpha extraction has its own update path and should not be assumed to read back the texture on every bend.
- Retain unaffected shapes, including extruded planes with bending disabled, and compare effective clamped angles before rebuilding. Avoid angle quantization.
- Reuse invariant topology/UV data and consider accumulating bounds during emission. C++ tangent generation already occurs during buffer completion; the GML tangent helper returns early for C++, so there is no second native tangent pass to remove.

Measure generation, normals, tangents, bounds, vertex counts, and allocation separately. Compare zero/tiny/large bends, all directions, multiple axes, inversion, offsets, sharp/smooth lighting, alpha masks, and normal maps. Investigate the extruded-plane `segoutersize`/`seginnersize` stepping discrepancy separately as a correctness question.

Sources: [blocks](../GmProject/scripts/model_shape_generate_block/model_shape_generate_block.gml), [flat planes](../GmProject/scripts/model_shape_generate_plane/model_shape_generate_plane.gml), [extruded planes](../GmProject/scripts/model_shape_generate_plane_3d/model_shape_generate_plane_3d.gml), [bend matrix](../GmProject/scripts/model_part_get_bend_matrix/model_part_get_bend_matrix.gml), [pinching](../GmProject/scripts/model_shape_get_bend_scale/model_shape_get_bend_scale.gml), [triangle emission](../GmProject/scripts/vbuffer_add_triangle/vbuffer_add_triangle.gml), [buffer completion](../CppProject/Asset/VertexBuffer.cpp).

### P04: Retain bend topology and buffers

avoid destroying and recreating complete mesh resources for every changed bend angle.

Separate topology/material inputs from animated deformation. Preserve mesh capacity and topology while they are valid; rebuild for shape, texture/alpha, or bend-style changes, including style changes at zero degrees. Retain unaffected shapes. Measure resource creation, uploaded bytes, tangent/bounds work, and batch reconstruction.

Compare two approaches as separate substeps:

- **P04a: retained CPU deformation.** Update deforming attributes in persistent buffers and rebuild indices only when needed. Account for deduplication changes, resources still in GPU use, and geometry revisions in cached batches.
- **P04b: GPU bending.** Generate tessellated blocks, flat planes, and extruded 3D planes in their rest pose. Animate deformation through per-object shader parameters. Put shared bending math in a `common_bend` include reached through common position code, covering color, depth, shadows, picking, and material passes. Keep attachment, IK, and parent-bend calculations available on the CPU.

For GPU deformation, retain shape rotation, corner-offset interpolation, UVs, segmentation, and generator-specific sharp/smooth behavior. Reconstruct appropriate normals and tangents from deformed geometry, including averaged offset-plane quad normals. Keep per-object parameters correct through instancing and cached batches. Use conservative deformation bounds and evaluate wind height eligibility from deformed positions.

Prefer optional bend attributes so ordinary vertex formats remain unchanged. Budget tessellation at zero bend, neighboring-point attributes, per-triangle duplication, mixed-batch storage, bandwidth, and repeated shader work in every pass. Compare float precision and normal packing; a conservative bound may submit more geometry. Exact rendered parity cannot be assumed from matching double-precision CPU arithmetic alone.

Persistent buffer IDs need care: cached CPU-deformed batches require geometry revisions or invalidation. Static GPU-deformed batch geometry can be reused only if dynamic parameters remain associated with the correct objects.

Sources: [bend updates](../GmProject/scripts/tl_update_model_shape_bend/tl_update_model_shape_bend.gml), [geometry generation](../GmProject/scripts/model_part_fill_shape_vbuffer_map/model_part_fill_shape_vbuffer_map.gml), [buffer resources](../CppProject/Render/Mesh.cpp), [batch matching](../CppProject/Render/VertexBufferRenderer.cpp), [common position shader](../GmProject/shaders/common_position/common_position.vsh).

### P05: Prepare rendering once and cull earlier

avoid repeated object/material/shape setup across playback render passes.

Prepare draw records and conservative world bounds by scene revisions, then derive pass-specific visible lists. Reject irrelevant candidates before expensive setup. Use type-specific dirty queues for text, items, and resource changes. Measure whether changing batch membership increases construction cost.

Retain useful existing caches and aggregate culling. Shadow rejection must use the light's caster volume, not camera visibility. Wind, bending, particles, and camera-facing shapes need safe bounds.

Sources: [render preparation](../GmProject/scripts/render_start/render_start.gml), [shape rendering](../GmProject/scripts/render_world_model_part/render_world_model_part.gml), [native culling/batching](../CppProject/Render/VertexBufferRenderer.cpp).

### P06: Restrict IK, path, and pose work to dependencies

avoid repeated searches and unrelated timeline scans during playback.

Track direct indices/subtrees, reverse dependencies, and deduplicated dirty roots. Retain path metadata and prefix distances where valid. Cache stable path/IK membership and capabilities by structural/resource revisions instead of rediscovering them each step, including scenes with no active IK.

Preserve solver chain order and transforms consumed by later solves, paths, and inherited poses. A single delayed update cannot replace every propagation step safely. Keep solver tolerances and iteration behavior unchanged initially.

Sources: [IK orchestration](../GmProject/scripts/tl_update_ik/tl_update_ik.gml), [paths](../GmProject/scripts/tl_update_path/tl_update_path.gml), [animation orchestration](../GmProject/scripts/app_update_animate/app_update_animate.gml).

### P07: Keep transform calculations native

reduce dynamic matrix/vector conversions and repeated object/member resolution.

Move the timeline transform sequence into typed C++ with fixed-size native intermediates. Keep parent, pre-IK, local, and render matrices native between updates. Construct rotation-to matrices directly and use native matrix mutation where required. Publish compatible values at GML boundaries and preserve nullable consumers.

Resolve typed objects once within their valid scope. Registered members already use indexed storage; ordinary member access is not uniformly a hash lookup. Prioritize conversion/allocation removal before SIMD. Retain a GML reference for differential comparisons.

Compare nested parents, bend locks, path endpoints, IK, inherited poses, resize/non-inherited scale, disabled position/rotation inheritance, camera orbits, and exact transform multiplication order.

Sources: [matrix orchestration](../GmProject/scripts/tl_update_matrix/tl_update_matrix.gml), [rotation-to helper](../GmProject/scripts/matrix_create_rotate_to/matrix_create_rotate_to.gml), [matrix representation](../CppProject/Type/MatrixType.cpp), [member access](../CppProject/Asset/Object.hpp).

### P08: Improve batch reuse and render-state submission

reduce batch searches, reconstruction, fragmentation, and redundant uploads.

Hash ordered mesh sequences with collision checks and geometry revisions instead of linearly searching prior batches. Attribute flushes to state, texture, and capacity changes; group compatible opaque work where ordering permits. Investigate dirty constant-buffer uploads and indexed blend-state lookup.

Preserve transparency/custom order and graphics hazards. Large-mesh instancing, aggregate rejection, and populated-prefix object uploads already exist. Measure this together with P04/P05 to avoid counting the same saving twice.

Sources: [batch cache](../CppProject/Render/VertexBufferRenderer.cpp), [shader uploads](../CppProject/Asset/Shader.cpp), [render states](../CppProject/Render/GraphicsApiHandler.cpp).

### P09: Reuse scenery-copy setup

avoid repeating full resource/material and transform setup for every scenery copy and pass.

Prepare compatible instance lists and reject invisible copy ranges before the three nested repetition loops submit their work. Native draw batching alone does not eliminate script-level setup.

Preserve axis conventions, fractional repetition, transparent ordering, material state, and off-camera shadow casters. Promote this work when repeated scenery dominates playback.

Source: [scenery rendering](../GmProject/scripts/render_world_scenery/render_world_scenery.gml).

### P10: Reduce particle simulation costs

reduce per-particle/per-step work and path-attractor searches.

Use typed contiguous simulation data, pooled storage, and hoisted spawner/type parameters. Accelerate searches over the same sampled path candidates while preserving ties and a correct fallback. Measure scaling with missed steps, particle count, and path sample count.

Preserve random/event order, lifetime/freeze behavior, hidden simulation, and seeks. Nearest-curve attraction, capped catch-up, and relaxed simulation change behavior. Separate global mutation before considering parallel execution.

Source: [particle simulation](../GmProject/scripts/particle_spawner_update/particle_spawner_update.gml).

### P11: Replace quadratic depth sorting

rebuild custom-depth/transparent timeline order in O(T log T).

Collect records and use a stable native sort instead of scanning insertion positions and shifting list entries. Retain no-change caching, category placement, equal-key order, and distance direction. Particle sorting within a spawner is a separate concern.

Measure normal sorting with matching visual output. A temporary sorting bypass can identify cost but must not be included as a production performance gain.

Source: [depth-list rebuilding](../GmProject/scripts/render_update_depth_list/render_update_depth_list.gml).

### P12: Generate geometry after the final required pose

avoid intermediate meshes that no consumer uses.

Count actual mesh generations per part/frame and identify their causes before deferring them. Bend checks can occur before and after IK/path propagation, but unchanged-angle guards already skip work; internal FABRIK iterations do not each generate meshes.

If redundant generations are material, mark geometry dirty and finalize before its first consumer. Keep transforms available to dependent solves and handle previews, picking, resource changes, and cached mesh handles. Retained GPU deformation reduces this proposal's angle-change workload but does not remove topology invalidation concerns.

Sources: [update ordering](../GmProject/scripts/tl_update_matrix/tl_update_matrix.gml), [bend guard](../GmProject/scripts/tl_update_model_shape_bend/tl_update_model_shape_bend.gml).

### P13: Reduce picking readback

avoid full-surface transfer and synchronization when only one pixel is needed.

Extend asynchronous single-pixel hover reads where latency is acceptable, retaining a current synchronous single-pixel fallback for clicks. Preserve render generation, coordinates, matrices, and ID mappings. Measure playback with picking active and inactive to isolate the cost.

Sources: [pixel API](../CppProject/Gml/RenderFunc.cpp), [surface reads](../CppProject/Asset/Surface.cpp), [build-mode picking](../GmProject/scripts/view_get_place_pixel/view_get_place_pixel.gml).

### P14: Reduce maintenance and lifetime churn

improve worst-frame latency and long-session playback stability.

Measure and budget periodic vector/font/string cleanup, deferred GL deletion, and shader checks. `fps_real` is sampled before maintenance and can miss its cost. Record full wall-clock frame distributions too.

Reduce mesh/resource churn before recycling asset slots. New assets append slots while destroyed assets leave cleared entries; recycling needs protection against stale IDs and cannot simply compact the array.

Sources: [maintenance](../CppProject/AppHandler.cpp), [asset lifetime](../CppProject/Asset/Asset.cpp), [slot storage](../CppProject/FastVector.hpp).

### P15: Reduce editor and additional-view work

update UI, previews, and views only when playback requires it.

Measure main/secondary views, previews and their particles, timeline drawing, text/layout, gizmos, and other UI separately. Use visibility and dirty state where existing guards do not already help. Preserve input, detached windows, hidden simulation, and correct invalidation.

Cache appropriate timeline classifications, camera/spawner/light membership, and block-render capability by structural/resource revisions. Select the first active camera/environment in timeline order without repeated redundant discovery. Invalidate camera-effect caches when relevant inputs change rather than unconditionally, where dependencies permit.

Compare editor and headless performance on the same project before attributing their difference to rendering. Treat list/capability caching separately from P06's dependency scheduling.

Sources: [editor step](../GmProject/scripts/app_event_step/app_event_step.gml), [previews](../GmProject/scripts/app_update_previews/app_update_previews.gml), [animation setup](../GmProject/scripts/app_update_animate/app_update_animate.gml), [camera effects](../GmProject/scripts/tl_camera_effects_reset/tl_camera_effects_reset.gml).

### P16: Pipeline export

overlap completed-frame readback, conversion, encoding/compression, and storage.

Pool staging/video resources and queue immutable CPU frame data through a bounded readback ring and ordered output workers. Retain source resources until transfer completes, preserve frame/audio order and cancellation, and bound memory/backpressure.

Keep export measurements separate from interactive playback. Report end-to-end throughput; faster enqueue time alone does not prove a saving, and a single image may benefit much less than a sequence.

Sources: [GPU readback](../CppProject/Render/FrameBuffer.cpp), [movie encoding](../CppProject/Library/MovieLib.cpp), [export loop](../GmProject/scripts/export_update/export_update.gml).

### P17: Batch channel checks and retain shape-cache storage

remove repeated evaluation overhead and cache churn when many timelines animate.

- **P17a: native channel checks.** Resolve the timeline and selected keyframe arrays once per phase. Skip the full evaluator when the current value equals both endpoints, or equals the selected keyframe/default outside interpolation. Evaluate transitions before computing easing, then ordinary channels in their existing order. Preserve enabled groups, path exclusions, effect exceptions, audio, and particle events. Borrow only for the current call so edits, seeks, reverse playback, and loop adjustments need no persistent reference invalidation. Precomputed varying-channel masks are a further option if cheap checks remain significant; they require edit/interval invalidation.
- **P17b: retained shape-cache storage.** Distinguish part/topology identity from ordinary movement. Overwrite existing native matrix slots instead of clearing their owning array. Refresh buffer-map and hidden-shape metadata only when needed; invalidate for part/count, geometry, texture, visibility, and structural changes. Keep conservative full/render fallback refreshes and per-view paths for item-bounce/camera-facing shapes. Discard unused trailing cache entries after shrinking.

Measure scoped evaluator calls, value comparisons, allocations, metadata lookups, and shape products separately. For example, 288 timelines visiting 46 channels produce 13,248 candidate evaluator calls; a batch still checks values even if only one channel per timeline needs interpolation. Call-count reductions are not equivalent percentages of total CPU work.

Compare all enabled channel groups, defaults, endpoints, duplicate positions, changing interval data, forward/reverse/seamless playback, edits, empty/null shape lists, same-part geometry changes, mesh/hidden-list changes, and camera-facing slots.

Sources: [animation](../GmProject/scripts/tl_update_values/tl_update_values.gml), [evaluator](../GmProject/scripts/tl_update_values_ease/tl_update_values_ease.gml), [shape cache](../GmProject/scripts/tl_update_model_shape_render/tl_update_model_shape_render.gml).

### P18: Remove remaining repeated animation and matrix work

extend targeted updates and native batching with four independently measurable substeps.

- **P18a: separate bend and rigid dirtiness.** A part's own bend can change deformation without changing its rigid matrix. Skip its rigid/shape-matrix products when safe, but continue bend updates and world invalidation. Retain dependent-child transform updates for bend locks/descendants and conservative paths for active IK, parent movement, inherited poses, and explicit/full updates. CPU geometry rebuilds must still invalidate shape matrices/metadata. Compare this substep both before and after GPU bending.
- **P18b: native shape-cache refresh.** Resolve the part, shape list, output arrays, world matrix, and metadata containers once, then each shape once. Retain P17's storage/invalidation rules. Guard empty parts before resolving template metadata, handle undefined buffer handles, and preserve hidden, camera-facing, and item-bounce behavior.
- **P18c: reuse local and model-part transforms.** Cache local matrices by exact position/rotation/scale inputs so parent-only movement avoids reconstructing them. Cache model-part offset/rotation matrices by identity and actual inputs, including same-part edits and `part_of` changes. Keep current world composition and resize/inheritance behavior. Avoid epsilon/quantization; a changed local input can initially rebuild the complete local matrix. A specialized translation-only path is a separate experiment.
- **P18d: direct native evaluation of affected channels.** Use the endpoints already resolved by the batch instead of re-entering a scoped evaluator. Borrow interpolation inputs, preserve color mixing, flooring, discrete values, and arithmetic order, then accumulate dirty categories and assign changed results. Keep reference logic for comparisons and verify categories for every channel independently.

Measure rigid updates versus bend updates, local/offset matrix constructions, cache hits, scoped calls, and interpolation time. Compare bend-only independent timelines, bend-locked descendants, active IK, inherited poses, paths, local edits, tiny offset changes, part/type/null changes, visibility/texture edits, and full invalidation. Account for fixed cache storage per timeline.

Sources: [dirty flags](../GmProject/scripts/tl_update_values_ease/tl_update_values_ease.gml), [transform scheduling](../GmProject/scripts/tl_update_matrix/tl_update_matrix.gml), [shape refresh](../GmProject/scripts/tl_update_model_shape_render/tl_update_model_shape_render.gml), [interpolation rules](../GmProject/scripts/tl_value_interpolate/tl_value_interpolate.gml).

## Measurement and proposed acceptance order

Use this analysis as the documentation baseline. Introduce one proposal or named substep per subsequent commit, with its correctness evidence and benchmark results recorded alongside the change. Avoid restoring a combined patch when the aim is to attribute savings.

A dependency-aware starting sequence is P01, P02, P07, P17a, P17b, then P18 substeps. Measure P03 separately from P04's retained-buffer/GPU alternatives; revisit P18a after GPU bending. This is an integration sequence, not a performance ranking. If a substep needs a prerequisite, identify it explicitly and compare against the immediate parent commit as well as the original baseline.

Use a fixed playback suite:

- An empty project paused/playing, to expose fixed per-step overhead.
- Hundreds of independent timelines with one animated channel, followed by many animated channels.
- Parent-driven hierarchies, appearance-only changes, and a separate IK/path/inherited-pose scene.
- Bend-heavy blocks, flat planes, and extruded planes, including zero crossings and style changes.
- Representative transparent, scenery, particle, and editor-heavy scenes for workload-specific proposals.

Start with uncached Quick mode for the interactive playback case; keep resolution, camera, renderer, preview windows, selection/UI state, playback speed, VSync/frame limits, and project contents fixed. Separate paused steady state, continuous playback, scrubbing/seeking, and cold topology/resource changes. Do not compare cached paused output to uncached playback as if it measured animation alone.

Profile the C++ executable with optimized code and symbols (`RelWithDebInfo`). Regenerate C++ from the checked-out GML and build each recorded commit; use separate build directories or clear stale outputs so an earlier executable cannot become the baseline by accident. Keep shader/mesh cache preparation consistent. Record commit/build configuration, backend, project/range, settings, hardware, and repeat count. Warm up both versions, repeat the same range at least three times, and report median plus p95/p99 frame times in milliseconds. Report both incremental and cumulative changes; retain regressions and unsuccessful experiments in the record.

Separate animation/keyframe search, transforms/inheritance, IK/paths, actual geometry generations, tangent/bounds work, render preparation, batch lookup/upload, GPU waits, picking, editor UI, and maintenance. Record allocations/copied bytes, visit/update counts, rebuild causes, matrix counts, cache hits, and uploaded/resource counts. Count actual rebuilds rather than update-function entries.

`FPS real` is useful feedback but is not a CPU/GPU profiler. `Animate_ms` is a broad elapsed scope and excludes the movie camera-update call between its timed segments. `Render_ms` subtracts surface-helper timing rather than reporting GPU timestamps; `Surface_ms` includes checks as well as allocations. CPU/GPU overlap and blocking mean these numbers cannot simply be added.

When native validation/benchmarking is requested, follow AGENTS.md: launch from the build folder with `--test dev_project/dev_project.miproject --all --agent Codex`, or an explicitly selected project/range. Use `--start X --end Y` for an inclusive range. Test all renderers by default and run DirectX followed by `--gfx OpenGL` on Windows. Use the rendering test project when checking effects, with pass/shader dumps as needed.

Compare against baselines where available. Check expected images are present, nonzero, and nonblack, inspect logs, and compare geometry, packed attributes, and rendered output. Cover sharp/smooth/multi-axis bends, offsets, fractional/mirrored UVs, alpha masks, normal maps, wind, shadows/picking, sorting, particles, hierarchy/resource edits, and seeks. Source-level replay can support these checks but does not replace native compilation, execution, image comparisons, or timing.
