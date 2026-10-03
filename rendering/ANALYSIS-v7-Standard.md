Prmpt:

*Look at the `e_renderer.STANDARD` render path for GameMaker, then the underlying C++ implementation in CppProject. What are the highest prio optimization opportunities for shadow rendering from the sunlight, with 1 or more cascades? List actions to take in the shader code, GML or CppProject engine under Render/ or Asset/.*

# Standard renderer: sunlight shadow optimization

The main sunlight costs in Standard are not the single-sample pipeline itself, but repeated scene submission per cascade and the PCSS lighting pass. I would prioritize reducing submitted shadow geometry first, then specialize the sunlight shader, then improve shadow-map storage.

## Current Standard path

Standard calls `render_high()`, but limits it to one sample in [render_high.gml (line 10)](D:/Projects/Mine-imator/GmProject/scripts/render_high/render_high.gml:10). It still performs the complete G-buffer and high-quality shadow pipeline.

For sunlight, every frame currently performs:

1. Recalculate view-dependent cascade matrices
2. Traverse and render the scene once per cascade using `HIGH_LIGHT_SUN_DEPTH`
3. Traverse and render the scene again using `HIGH_LIGHT_SUN`
4. Copy the diffuse and specular sunlight results into their final surfaces

Balanced Standard defaults to two 2048² cascades and PCSS quality 20. Quality 20 can issue up to 31 depth reads per affected fragment: one center sample, ten blocker samples and twenty filter samples.

## Priority 0: establish accurate comparisons

Before larger optimizations:

- Add GPU timestamp queries around each cascade and the sun-lighting pass under CppProject/Render. CPU timers do not reliably measure asynchronously queued GPU work.
- Record submitted objects, triangles and draw calls separately for each cascade.
- Benchmark 1, 2 and 3 cascades over an equivalent shadow range.

The current split tables in [render_update_cascades.gml (line 6)](D:/Projects/Mine-imator/GmProject/scripts/render_update_cascades/render_update_cascades.gml:6) end at:

- One cascade: 5% of the configured distance
- Two cascades: 20%
- Three cascades: 100%

Consequently, fewer cascades currently also shadow much less of the scene. This can make cascade-count performance comparisons misleading. If reduced maximum distance is intentional, it should be a separate shadow-distance setting.

Also remove both `cam_frustum.build()` and the unconditional `cam_frustum.build_vbuffer()` at [render_update_cascades.gml (line 17)](D:/Projects/Mine-imator/GmProject/scripts/render_update_cascades/render_update_cascades.gml:17). Repository-wide usage shows that this camera frustum vertex buffer is not rendered or otherwise consumed. It is destroyed and recreated every cascade update.

## Highest-priority optimizations

| Priority | Area | Action |
| --- | --- | --- |
| 1 | C++ culling/batching | Cull individual objects before adding them to a shadow batch |
| 2 | Sun shader | Compile dedicated 1-, 2- and 3-cascade variants |
| 3 | Sun shader | Specialize hard-shadow and PCSS quality paths |
| 4 | GML/shader | Replace the forward sunlight redraw with a fullscreen G-buffer pass |
| 5 | C++ framebuffer | Add a shader-readable depth-only shadow surface |
| 6 | GML | Cache static or unchanged cascade contents |
| 7 | GML | Accumulate sunlight directly into final MRT targets |

### 1. Cull before batching

[VertexBufferRenderer.cpp (line 30)](D:/Projects/Mine-imator/CppProject/Render/VertexBufferRenderer.cpp:30) combines object bounds into one batch and only tests the aggregate bounds at line 80. A large batch intersecting the near cascade therefore submits all its geometry, including objects well outside that cascade.

Actions:

- Transform and test each object's bounds before adding it to the batch
- Exclude invisible objects from both the batch geometry and object uniform array
- Alternatively, construct spatially local batches or bounded clusters
- Maintain a shadow-caster list so each cascade does not traverse every timeline object
- Cache transformed bounds until the object's matrix or geometry changes

Also replace the allocation-heavy eight-corner test in [GraphicsApiHandler.cpp (line 739)](D:/Projects/Mine-imator/CppProject/Render/GraphicsApiHandler.cpp:739) with an allocation-free AABB/plane test using center and extents. It currently creates a QVector for every visibility test, multiplied by every render pass and cascade.

This is likely the largest improvement in scenery-heavy projects because its benefit scales directly with cascade count.

### 2. Add cascade-count shader variants

The current sun vertex shader always calculates three shadow coordinates, even with one cascade. The fragment shader likewise calculates three receiver-depth gradients before determining which cascade is needed.

Actions in `shader_high_light_sun`:

- Compile `SUN_1`, `SUN_2` and `SUN_3` variants
- Declare only the required matrices, varyings and samplers
- Calculate the receiver gradient only after selecting the cascade
- Remove the runtime cascade loop and sampler-selection chain from the one-cascade variant
- Do not bind aliases of cascade zero for missing cascades

The one-cascade Standard path would then use one matrix multiplication per vertex, one shadow varying and one gradient calculation instead of three.
### 3. Specialize PCSS paths

The runtime loops in [shader_high_light_sun.fsh (line 42)](D:/Projects/Mine-imator/GmProject/shaders/shader_high_light_sun/shader_high_light_sun.fsh:42) have maximum bounds of 16 blocker and 64 filter samples.

Actions:

- Create a hard-shadow variant that contains no PCSS rotation, derivatives or loops
- Compile a small number of PCSS quality buckets, such as 4, 10, 20 and 50/64
- Give Standard its own bounded quality variants
- Consider a min-depth hierarchy for conservative blocker-free rejection before the blocker search
- Move sky/background rejection ahead of material and shadow calculations where possible

Static loop sizes give D3D and OpenGL compilers better unrolling opportunities and avoid carrying the maximum-size path into every preset.

### 4. Convert sunlight shading to a fullscreen pass

After render_high_create_gbuffers(), the renderer already has diffuse, depth, normal, roughness, metallic, Fresnel and SSS information. Nevertheless, [render_high_shadows.gml (line 99)](D:/Projects/Mine-imator/GmProject/scripts/render_high_shadows/render_high_shadows.gml:99) redraws all scene geometry for sunlight.

A fullscreen sun shader could:

- Reconstruct world position from the depth buffer
- Read the already mapped normal and material values
- Select and sample the cascade
- Produce diffuse sunlight and specular output as MRTs

This removes an entire GML scene traversal, vertex processing, material submission and geometry overdraw per sun. Transparent/water/SSS behavior must be compared carefully because blended G-buffer data may not exactly reproduce the current forward pass.

### 5. Add depth-only shadow surfaces

Each current cascade requests an r32float color surface with a separate depth buffer at [render_high_shadows.gml (line 80)](D:/Projects/Mine-imator/GmProject/scripts/render_high_shadows/render_high_shadows.gml:80).

In C++, that becomes:

- R32 color texture with RTV/SRV
- Separate D24S8 depth allocation

The fragment shader then writes depth into the R32 color target. This doubles shadow-map storage and writes both color and hardware depth.

Actions under CppProject/Render and Asset:

- Add a shader-readable depth surface type
- D3D11: typeless R32 texture with D32_FLOAT DSV and R32_FLOAT SRV
- OpenGL: GL_DEPTH_COMPONENT32F depth texture attachment
- Expose the depth texture to surface_get_texture, or add a dedicated internal shadow accessor
- Add an opaque caster shader that requires no texture sample or color output
- Retain a separate alpha-tested shader for cutout/transparent casters

### 6. Cache cascades carefully

Standard disables jittered shadows, so unchanged cascade maps can be reused. However, the current cascade matrices are view-dependent: they use camera position, direction, FOV, aspect and split range. An unchanged sun direction alone is insufficient for reuse across viewports.

Useful strategies:

- Cache a cascade while its snapped matrix, sun direction, resolution and caster revision remain unchanged
- Split static scenery and dynamic casters into separate shadow maps
- Cache the static map and combine it with dynamic-caster depth
- Update distant cascades less frequently for interactive rendering, but not exact movie export
- Keep caches per viewport unless their final snapped light matrices are identical

### 7. Remove sunlight copy passes

The sunlight pass writes to two HDR temporary surfaces and then performs two fullscreen additive copies at [render_high_shadows.gml (line 109)](D:/Projects/Mine-imator/GmProject/scripts/render_high_shadows/render_high_shadows.gml:109).

Bind `render_surface_shadows` and `render_surface_specular` directly as MRT outputs with additive blending. This removes two fullscreen draws, two target changes and unnecessary memory bandwidth. It is a relatively low-risk GML optimization.

## Lower-priority engine work

After reducing draw count:

- Avoid unbinding every sampler and SRV after every draw in [Shader.cpp (line 886)](D:/Projects/Mine-imator/CppProject/Asset/Shader.cpp:886); only unbind resources that will become render targets
- Consider a cascade texture array or atlas to reduce bindings and target switching
- Cache shadow-specific batches and caster lists across frames
- Add spatial clustering for large scenery buffers

A texture array alone will not reduce geometry traversal, so I would not prioritize it above culling, shader specialization or depth-only storage.
