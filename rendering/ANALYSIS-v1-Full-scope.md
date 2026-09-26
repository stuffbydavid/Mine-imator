Prompt:

*Investigate the shaders and rendering classes used in Mine-imator/CppProject. Focus on the DirectX/D3D path for now. Find potential for speedups and optimizations on the CPU/GPU side for maximum framerate, especially regarding shadows, ray tracing and other intense effects using accumulated samples.
Then, find implications for the OpenGL renderer or low-end/integrated graphics cards if the proposed architectural changes are implemented.*


# Rendering Performance Investigation

The largest framerate losses are structural rather than individual shader instructions. The current high-quality path redraws most of the scene many times per accumulated sample, then moves large full-resolution buffers through several copy/composite passes.
This was a static, read-only investigation; I did not build or run the project.
## Rendering architecture
The DirectX backend is D3D11. The effects called “ray tracing” are screen-space pixel-shader ray marching—not DXR or hardware BVH ray tracing:
- Shaders compile as vs_4_0/ps_4_0: [ShaderLoadD3D11.cpp (line 360)](../CppProject/Asset/ShaderLoadD3D11.cpp#L360)
- Screen-space rays march the packed depth buffer for up to roughly 256 × (1 + precision) iterations: [shader_high_raytrace.fsh (line 142)](../CppProject/Asset/Shaders/shader_high_raytrace.fsh#L142)
- One stochastic sample is rendered per application frame until the requested count is reached: [render_high.gml (line 14)](../GmProject/scripts/render_high/render_high.gml#L14), [render_update_samples.gml (line 28)](../GmProject/scripts/render_update_samples/render_update_samples.gml#L28)
At the default 24 samples, essentially the entire expensive render graph runs 24 times.
## Highest-impact opportunities

### 1. Convert lighting to deferred or tiled deferred rendering
Currently, the scene is rerendered with full geometry for the sun, each point/spot light, shadowless lights, glint, and scene masks. Yet depth, normals, material, emissive, and diffuse G-buffers already exist.
The base passes alone rerender geometry three times per sample:
- Diffuse
- Depth + normals
- Material + emissive
See [render_high_passes.gml (line 24)](../GmProject/scripts/render_high_passes/render_high_passes.gml#L24).
Then every light again calls render_world(): [render_high_shadows.gml (line 103)](../GmProject/scripts/render_high_shadows/render_high_shadows.gml#L103).
Recommended design:
- Produce diffuse, material, emissive, normal, and linear depth in one MRT geometry pass.
- Reconstruct world/view position from depth.
- Shade the sun with one fullscreen pass.
- Shade point/spot lights using bounded light volumes or tiled/clustered compute.
- Fold AO/glint/scene masks into G-buffer channels where practical.
This should remove most repeated CPU traversal, vertex processing, texture/material sampling, and draw submission. It is likely the single largest general speedup.
### 2. Redesign point-light shadows
One shadowed point light currently performs:
- Six complete shadow-depth scene renders.
- Six surface-to-atlas copies.
- Another scene render for lighting.
- Additional fullscreen diffuse/specular composites.
The six-face loop and copies are visible in [render_high_shadows.gml (line 175)](../GmProject/scripts/render_high_shadows/render_high_shadows.gml#L175).
Improvements, ordered by effort:
- Render each face directly into its atlas viewport, eliminating the six temporary-surface copies.
- Better: use a depth cubemap or Texture2DArray with per-face DSVs.
- Best D3D11 path: use instancing plus a geometry shader to emit all six cube faces in one scene submission.
- Cache shadow maps until either the light or a shadow-casting object changes.
- For accumulated soft shadows, consider a stable shadow map plus stochastic PCF/PCSS sampling instead of moving the light and rerendering six maps every sample.
The same caching applies to sun cascades and spot shadows. Static scenes should not regenerate every shadow map solely because another camera accumulation sample is being added.
### 3. Replace the three-texture packed accumulator
Accumulation currently stores RGB across two RGBA8 surfaces and alpha in a third. Every new sample:
- Copies up to three previous accumulation surfaces to temporary surfaces.
- Reads those temporaries.
- Reads the new sample.
- Writes three MRTs.
- Runs another unpack pass every frame.
See [render_high_samples_add.gml (line 21)](../GmProject/scripts/render_high_samples_add/render_high_samples_add.gml#L21) and [shader_high_samples_add.fsh (line 18)](../CppProject/Asset/Shaders/shader_high_samples_add.fsh#L18).
Use one R16G16B16A16_FLOAT accumulation target with additive blending, followed by division by the sample count. Even RGBA32F would usually move less data than the present copy/pack scheme.
This removes:
- Two or three persistent accumulation surfaces.
- Two or three copies per sample.
- Integer-like packing/unpacking ALU.
- Most MRT bandwidth.
- The need for ping-pong temporaries.
### 4. Stop rerendering after accumulation completes
When render_samples_done is true, the expensive sample loop is skipped, but the code still:
- Unpacks the accumulated image.
- Copies it to another surface.
- Reapplies final post-processing.
- Copies it back.
See [render_high.gml (line 87)](../GmProject/scripts/render_high/render_high.gml#L87).
Cache the final post-processed result and simply display it until the camera, scene, resolution, or render settings invalidate it. This could greatly increase steady-state editor framerate after convergence.
### 5. Use smaller, purpose-specific render-target formats
FrameBuffer offers only two color formats:
- RGBA8
- RGBA32F
[FrameBuffer.cpp (line 38)](../CppProject/Render/FrameBuffer.cpp#L38)
Consequently, HDR lighting and normal buffers use 16 bytes per pixel. Recommended formats include:
- HDR lighting: R11G11B10_FLOAT where alpha is unnecessary.
- HDR with alpha: R16G16B16A16_FLOAT.
- Normals: R10G10B10A2_UNORM, R16G16_SNORM, or octahedral two-channel encoding.
- Linear depth: R32_FLOAT or R16_FLOAT, depending on range requirements.
- Emissive/masks: single- or dual-channel formats.
At 1080p, replacing one RGBA32F target with RGBA16F saves about 16 MB of traffic per complete read/write cycle. The current graph performs many such cycles per sample.
## Ray-tracing/SSGI path
The ray pass nominally uses checkerboard casting, but it still launches a full-resolution pixel shader. Every pixel samples depth, and reflection pixels sample material before the checkerboard decision: [shader_high_raytrace.fsh (line 242)](../CppProject/Asset/Shaders/shader_high_raytrace.fsh#L242).
Recommended changes:
- Render rays into a real half-resolution target and bilateral-upsample. That processes 25% of full-resolution pixels rather than launching all pixels and tracing 50%.
- Alternatively, add a dedicated SM5 compute path and dispatch only active ray pixels.
- Encode view-space Z directly. The inner ray loop currently performs a matrix-based position reconstruction for every depth sample.
- Add hierarchical-Z depth mips and traverse coarse-to-fine. This can reduce hundreds of linear steps to tens of mip-assisted steps.
- Specialize separate reflection and indirect shaders. uRayType currently leaves divergent branches in one large shader.
- Remove unused uniforms such as uViewMatrixInv, uCameraPosition, and uFogColor.
- Fix the potentially undefined first use of deltaPrev in the ray loop.
The bilateral resolve also issues up to four neighbor depth, normal, material, and color samples per missing pixel: [shader_high_raytrace_resolve.fsh (line 27)](../CppProject/Asset/Shaders/shader_high_raytrace_resolve.fsh#L27). A half-resolution source with an optimized gather-based upsampler would be more coherent.
## Shadow-map representation
Shadow depths are manually packed into RGBA color targets and unpacked in lighting shaders. Point shadows additionally perform manual four-tap filtering: [shader_high_light_point.fsh (line 121)](../CppProject/Asset/Shaders/shader_high_light_point.fsh#L121).
A D3D-specific fast path should use:
- Typeless depth textures.
- DSVs for rendering.
- Depth SRVs for sampling.
- Comparison samplers and hardware PCF.
That removes depth-pack fragment ALU, depth-unpack ALU, manual comparison logic, and much of the point-shadow filtering code. It also enables hierarchical depth behavior during shadow rendering.
## D3D11 CPU submission overhead
Several hot-path operations happen for every draw:
- Temporary QVector allocations for samplers, SRVs, and constant buffers.
- All samplers and SRVs are rebound.
- All samplers and SRVs are explicitly nulled after every draw.
- The complete static constant buffer is uploaded every draw.
- The complete object constant buffer—up to 64 KB—is uploaded even when only a small batch is used.
See [Shader.cpp (line 627)](../CppProject/Asset/Shader.cpp#L627).
Recommended changes:
- Replace temporary QVectors with fixed arrays.
- Track currently bound shaders, input layout, topology, SRVs, samplers, and constant buffers.
- Unbind only resources that conflict with an upcoming RTV/DSV.
- Dirty-track constant buffers.
- Split frame/pass/material/object constants.
- Use dynamic constant-buffer rings or D3D11.1 constant-buffer ranges.
- Upload only the used object count rather than the entire 64 KB backing buffer.
- Replace hot indexed QHash storage for uniforms with contiguous vectors.
There is also a leak in presentation: OMGetBlendState adds a COM reference, but prevState is never released: [AppWindow.cpp (line 142)](../CppProject/AppWindow.cpp#L142).
SubmitMat4Array() similarly allocates a float array without deleting it: [Shader.cpp (line 450)](../CppProject/Asset/Shader.cpp#L450).
## Vertex and raster costs
The depth/normal vertex shader computes a complete inverse-transpose 3×3 matrix per vertex: [shader_high_depth_normal.vsh (line 79)](../CppProject/Asset/Shaders/shader_high_depth_normal.vsh#L79).
It also declares far more interpolators than the pixel shader needs, including matrices and duplicated normal/tangent data. Precompute the normal matrix per object on the CPU and submit only the required varyings.
The GLSL-to-HLSL converter also rewrites every for loop into a [loop] while, including small constant loops: [ShaderLoadD3D11.cpp (line 250)](../CppProject/Asset/ShaderLoadD3D11.cpp#L250). This can prevent desirable unrolling for:
- 12-tap SSAO.
- Three-cascade selection.
- Short GGX loops.
- Fixed blur kernels.
Preserve ordinary loops and explicitly use [unroll] for small constant kernels; reserve [loop] for the long ray march.
## Immediate low-risk wins
I would implement these first:
1. Fix the depth/normal enable condition. It is currently always true whenever the subsurface sample setting is nonnegative—even zero and even when shadows are disabled: [render_start.gml (line 31)](../GmProject/scripts/render_start/render_start.gml#L31).
2. Cache the final converged image and skip unpack/post passes when nothing changed.
3. Replace accumulated packing/copies with one floating-point additive surface.
4. Eliminate redundant clears before fullscreen shaders that overwrite every pixel.
5. Directly render point-shadow faces into the atlas instead of copying them.
6. Dirty-track D3D state and constant buffers.
7. Fix the COM and matrix-array leaks.
8. Cache SSAO kernels and camera inverse matrices instead of regenerating/reinverting them per effect per sample.
After those, the largest architectural work should be a combined G-buffer plus deferred/tiled lighting path. A D3D12/DXR backend would be required for actual hardware ray tracing, but the current screen-space path has substantial headroom before that migration becomes necessary.

---

# Deferred and Tiled Deferred Rendering Follow-up

## Conclusion

The deferred-sun conversion is feasible without hand-written C++ renderer changes. The existing D3D11 backend already supports MRT binding through [`surface_set_target_ext` (line 467)](../CppProject/Gml/RenderFunc.cpp#L467) and translates `gl_FragData[n]` into D3D render targets in [ShaderLoadD3D11.cpp (line 130)](../CppProject/Asset/ShaderLoadD3D11.cpp#L130).
It cannot be literally .gml-only, however: it requires new .vsh/.fsh/.yy shader assets. CppGen will then copy/transpile those and the GML into CppProject/Asset/Shaders and CppProject/Generated as part of its normal process ([Program.cpp (line 30)](../CppGen/Sources/Program.cpp#L30)). No changes to the handwritten D3D11 classes should be necessary.
No code was changed or built during this investigation.
## Proposed render graph

| Stage | Current | Proposed |
|---|---|---|
| Camera geometry | Diffuse pass | One 8-target MRT G-buffer pass |
| Camera geometry | Depth/normal pass | Folded into G-buffer |
| Camera geometry | Material/emissive pass | Folded into G-buffer |
| Sun shadow maps | Three cascade geometry passes | Unchanged |
| Sun lighting | Full scene geometry pass | One fullscreen pass |
| SSAO mask | Full scene geometry pass | Read a G-buffer channel |
| SSS properties | Full scene geometry pass | Read G-buffer targets |
| Scene mask | Full scene geometry pass | Read a G-buffer channel |
| Glint | Full scene geometry pass | Keep initially |


The core camera scene goes from four submissions per accumulated sample—three data passes plus sun lighting—to one geometry submission plus one fullscreen draw. At 128 samples, that removes 384 full scene traversals. The three sun cascade submissions are still required because they render from the light’s viewpoint.
## Recommended G-buffer layout
D3D11 supports eight simultaneous render targets, and the current backend accepts indices 0–7. A parity-oriented layout would use all eight:
| MRT | Surface | Contents |
|---:|---|---|
| 0 | `render_surface_diffuse` | Final color-adjusted albedo RGB, coverage alpha |
| 1 | `render_surface_depth` | Existing packed linear view depth RGB, coverage alpha |
| 2 | `render_surface_normal` | View-space mapped normal RGB, SSAO participation in A |
| 3 | `render_surface_material` | Roughness, metallic, view Fresnel, base F0 |
| 4 | `render_surface_emissive` | Existing packed emissive RGB, `isSky` in A |
| 5 | New `render_surface_sss` | Existing packed SSS strength RGB, scene mask in A |
| 6 | New `render_surface_sss_radius` | Per-pixel SSS radius RGB |
| 7 | New `render_surface_sss_color` | Per-pixel SSS color RGB |


This preserves the per-object SSS parameters currently used by [shader_high_light_sun.fsh (line 185)](../GmProject/shaders/shader_high_light_sun/shader_high_light_sun.fsh#L185). A smaller five- or six-target G-buffer would be easier, but would either lose SSS fidelity or require retaining another geometry pass.
## Step-by-step changes

### 1. Add a deferred render mode and feature switch

In [enums.gml (line 823)](../GmProject/scripts/enums/enums.gml#L823):

```gml
HIGH_GBUFFER,
```

Keep COLOR, HIGH_DEPTH_NORMAL, MATERIAL, and HIGH_LIGHT_SUN for fallback and render-pass debugging.

In [render_startup.gml (line 16)](../GmProject/scripts/render_startup/render_startup.gml#L16):

- Add render_deferred to the render globals.
- Add the three new named SSS surfaces.
- Initialize them to null.
- Map HIGH_GBUFFER to shader_high_gbuffer.

In [render_start.gml (line 22)](../GmProject/scripts/render_start/render_start.gml#L22):

```gml
render_deferred = is_cpp() && render_quality == e_view_mode.RENDER
render_depth_normals = render_deferred ||
                       render_ssao ||
                       render_indirect ||
                       render_reflections ||
                       project_render_subsurface_samples >= 0
```

Initially, I would also gate deferred rendering on alpha hashing and the absence of nonstandard object blend modes. That creates a visual-parity fallback while transparent rendering is being separated.

Add the new surfaces to the cleanup performed by render_free.gml.

### 2. Register the shaders

In [shader_startup.gml (line 31)](../GmProject/scripts/shader_startup/shader_startup.gml#L31), register:

```gml
new_shader("shader_high_gbuffer")
new_shader("shader_high_light_sun_deferred")
```

For shader_high_gbuffer:
- Call shader_material_uniforms().
- Register the color-adjustment uniforms currently used by shader_color_fog.
- Register uNear, uFar, uNormalBufferScale.
- Register uIsGround, uIsSky, and a new uSSAOEnabled.
For shader_high_light_sun_deferred, register:
- Eight G-buffer samplers.
- The three cascade shadow samplers.
- uLightMatBiasMVP, cascade near/far and cascade endpoints.
- uProjMatrixInv, uViewMatrixInv, uTAAMatrixInv.
- The existing sun color, direction, strength, specular and SSS-highlight uniforms.
Eleven pixel-shader samplers are needed—eight G-buffer plus three cascades—which remains below the D3D11 limit of sixteen.
### 3. Create the unified geometry shader
Add shader_high_gbuffer.vsh/.fsh/.yy.
The vertex shader should combine:
- Wind-deformed world position and TAA projection from shader_color_fog.
- TBN/view-space normal calculation from shader_high_depth_normal.
- Texture coordinates, vertex color, and custom material data from shader_high_material.
The fragment shader should:
1. Sample the diffuse texture once.
2. Apply the RGB/HSB/mix transformations currently performed by shader_color_fog.
3. Perform the alpha-zero and alpha-hash test once.
4. Sample the material and normal maps once.
5. Compute roughness, metallic, emissive, F0 and SSS once.
6. Write all eight gl_FragData outputs.
Do not apply Minecraft fog here; it is already applied later by [`render_high_fog` (line 59)](../GmProject/scripts/render_high/render_high.gml#L59).
### 4. Supply per-object mask data

In [render_world_tl.gml (line 74)](../GmProject/scripts/render_world_tl/render_world_tl.gml#L74), when render_mode == HIGH_GBUFFER, set:

```gml
render_set_uniform("uSSAOEnabled", ssao ? shader_blend_alpha : 0)
```

The existing uIsGround and uIsSky changes in [render_world_ground.gml (line 17)](../GmProject/scripts/render_world_ground/render_world_ground.gml#L17) and [render_world_sky_clouds.gml (line 17)](../GmProject/scripts/render_world_sky_clouds/render_world_sky_clouds.gml#L17) can be reused.
The G-buffer shader can derive:
- Scene mask: object/ground = 1, sky cloud = 0.
- SSAO mask: uSSAOEnabled.
- Sky flag: uIsSky.
### 5. Replace the three passes in `render_high_passes`

The repeated passes are currently in [render_high_passes.gml (line 24)](../GmProject/scripts/render_high_passes/render_high_passes.gml#L24).
The deferred branch should:
1. Require all eight same-sized surfaces.
2. Clear them individually to black/zero.
3. Render render_world_background() and render_world_sky() into the diffuse surface only.
4. Bind the G-buffer:

```gml
surface_set_target_ext(0, render_surface_diffuse)
surface_set_target_ext(1, render_surface_depth)
surface_set_target_ext(2, render_surface_normal)
surface_set_target_ext(3, render_surface_material)
surface_set_target_ext(4, render_surface_emissive)
surface_set_target_ext(5, render_surface_sss)
surface_set_target_ext(6, render_surface_sss_radius)
surface_set_target_ext(7, render_surface_sss_color)
```

5. Force overwrite blending:

```gml
gpu_set_blendmode_ext(bm_one, bm_zero)
```

6. Execute one camera render:

```gml
render_world_start(depth_far)
render_world(e_render_mode.HIGH_GBUFFER)
render_world_done()
```

7. Reset the MRT and blend mode.
8. Retain the existing diffuse alpha-fix section.
9. Preserve render-pass duplication for diffuse, depth, normal, and material outputs.
The diffuse surface must be MRT 0 because the D3D backend uses the first submitted framebuffer’s depth buffer ([GraphicsApiHandler.cpp (line 181)](../CppProject/Render/GraphicsApiHandler.cpp#L181)).
Explicit per-surface clears are preferable. On D3D, draw_clear only clears the primary surface while secondary MRTs are implicitly cleared when attached; relying on that behavior would differ from the OpenGL path.
### 6. Add the fullscreen sun shader
Create shader_high_light_sun_deferred.vsh/.fsh/.yy.
The vertex shader can be the same fullscreen quad shader used by [shader_high_raytrace.vsh (line 4)](../GmProject/shaders/shader_high_raytrace/shader_high_raytrace.vsh#L4).
The fragment shader should:
1. Reject pixels whose depth-buffer alpha indicates no geometry.
2. Unpack linear depth.
3. Reconstruct view position using the inverse projection and inverse TAA jitter.
4. Transform the position to world space with uViewMatrixInv.
5. Unpack the view-space normal.
6. Read material, SSS and sky data.
7. Select the cascade using reconstructed view depth.
8. Calculate:

```glsl
shadowCoord = uLightMatBiasMVP[cascade] * vec4(worldPosition, 1.0);
```

9. Reuse the existing shadow comparison, SSS-transmission and GGX calculations.
10. Write diffuse light to target 0 and specular light to target 1.
For jitter-correct reconstruction, use:

```glsl
viewPosition =
    uProjMatrixInv *
    uTAAMatrixInv *
    clipPosition;
```

The existing raytrace reconstruction only uses the inverse projection ([shader_high_raytrace.fsh (line 65)](../GmProject/shaders/shader_high_raytrace/shader_high_raytrace.fsh#L65)); copying that exactly would create small TAA-dependent misalignment between visible geometry and cascade shadows.
### 7. Add the deferred sun setter
Create shader_high_light_sun_deferred_set.gml, based on [shader_high_light_sun_set.gml (line 3)](../GmProject/scripts/shader_high_light_sun_set/shader_high_light_sun_set.gml#L3).
It should:
- Bind all G-buffer surfaces.
- Bind the three cascade maps.
- Set the cascade matrices and near/far values.
- Set matrix_inverse_ext(proj_matrix).
- Set matrix_inverse_ext(view_matrix).
- Set matrix_inverse_ext(taa_matrix).
- Set sun color, direction, strength and specular settings.
Cascade selection can be made cheaper and clearer by passing the three view-space split distances rather than reproducing the current non-divided clip-Z comparison. Those split distances can be calculated from render_cascade_ends, cam_near, and min(cam_far_prev, 7500) using the same formula as [render_update_cascades.gml (line 21)](../GmProject/scripts/render_update_cascades/render_update_cascades.gml#L21).
### 8. Replace only the sun-lighting scene pass
Keep the three cascade depth passes in [render_high_shadows.gml (line 74)](../GmProject/scripts/render_high_shadows/render_high_shadows.gml#L74).
Replace the camera-space sun render at lines 103–128 with:
1. Set a 2D orthographic projection. This is now essential because the last preceding pass left the camera configured for a sun cascade.
2. Bind render_surface_shadows and render_surface_specular as MRT 0/1.
3. Enable additive blending.
4. Set shader_high_light_sun_deferred.
5. Call its setter.
6. Draw one draw_blank(0, 0, render_width, render_height).
7. Restore normal blending and reset the target.
This writes directly into the final lighting surfaces and removes both temporary HDR outputs and their two additive copy operations for the sun.
It is safe for this first sun pass because attaching MRT 1 currently clears it in D3D. Rebinding these targets repeatedly for later point lights would clear the secondary target, so that optimization should not yet be reused for all local lights.
### 9. Remove three more geometry-mask passes
Once the MRT output is verified:
- In [render_high_ssao.gml (line 7)](../GmProject/scripts/render_high_ssao/render_high_ssao.gml#L7), remove the AO_MASK world pass and read the normal surface’s alpha channel.
- In [render_high_subsurface_scatter.gml (line 13)](../GmProject/scripts/render_high_subsurface_scatter/render_high_subsurface_scatter.gml#L13), remove the SUBSURFACE world pass and use render_surface_sss plus render_surface_sss_radius.
- In [render_high_scene.gml (line 42)](../GmProject/scripts/render_high_scene/render_high_scene.gml#L42), remove the SCENE_TEST world pass and use render_surface_sss.a as the lighting mask.
Keep the glint geometry pass initially. Folding it into the same pass while retaining full per-pixel SSS radius and color would exceed the eight-MRT limit unless those values were more aggressively packed.
## Transparency constraint
A G-buffer cannot correctly represent multiple alpha-blended layers, and one blend state applies to every MRT. The safe initial rollout is:
- Use deferred rendering for opaque and alpha-hashed projects.
- Retain the current forward path when alpha hashing is disabled or a timeline uses a non-normal blend mode.
- Later split render_world_tl into deferred opaque/alpha-hashed and forward transparent filters.
Trying to apply normal alpha blending to depth, normals and material targets would silently corrupt the G-buffer.
## Tiled deferred follow-up
The sun should remain a fullscreen pass; tiling a single directional light adds overhead without reducing work.
After the G-buffer exists, point and spot lights can stop rerendering geometry too. A GML-only intermediate improvement is deferred light volumes or screen-space scissored rectangles. Their shadow-map passes remain, but their lighting shaders read the G-buffer.
A genuine GPU tiled-deferred implementation would probably require CppProject work: compute shaders plus UAV/structured-buffer support, or another efficient way to upload per-tile light lists. The current shader pipeline exposes vertex/fragment shaders and ordinary samplers, so the “no C++ changes” assumption is sound for the MRT G-buffer and deferred sun, but not necessarily for true tiled local-light culling.

---

# OpenGL and Low-End GPU Implications

## Scope

The handwritten C++ renderer selects D3D11 on Windows and OpenGL on other operating systems: [Common.hpp (line 50)](../CppProject/Common.hpp#L50). The low-quality `render_low` path is separate from the high-quality accumulated renderer, so it remains unaffected if deferred rendering is enabled only for `e_view_mode.RENDER`.

The C++ OpenGL path uses desktop OpenGL rather than OpenGL ES. It requests a 4.3 Core context in [GraphicsApiHandler.cpp (line 380)](../CppProject/Render/GraphicsApiHandler.cpp#L380), but the shader loader can fall back to GLSL 4.0 or GLSL 1.50 when newer features do not compile: [Shader.cpp (line 84)](../CppProject/Asset/Shader.cpp#L84). Consequently, requesting OpenGL 4.3 is not equivalent to proving that eight draw buffers, eleven fragment samplers, or the desired render-target formats are usable.

If the proposed `render_deferred = is_cpp() && ...` gate is retained, the original GameMaker renderer is excluded. Removing that gate would require a separate capability and performance policy for the GameMaker/OpenGL or GLES runner.

## OpenGL compatibility findings

The basic MRT mechanism is already present:

- `SetMRTIndex` attaches each additional texture and calls `glDrawBuffers`: [GraphicsApiHandler.cpp (line 497)](../CppProject/Render/GraphicsApiHandler.cpp#L497).
- The shader converter maps contiguous `gl_FragData[0]` through `gl_FragData[n]` declarations to explicit output locations: [ShaderLoadOpenGL.cpp (line 38)](../CppProject/Asset/ShaderLoadOpenGL.cpp#L38).
- Mixed RGBA and RGBA32F color attachments are created by the existing framebuffer implementation: [FrameBuffer.cpp (line 195)](../CppProject/Render/FrameBuffer.cpp#L195).

Therefore, the proposed shader should work on an OpenGL driver that supports all eight targets and the required sampler count. There are several robustness gaps:

1. The renderer never queries `GL_MAX_DRAW_BUFFERS`, `GL_MAX_COLOR_ATTACHMENTS`, or `GL_MAX_TEXTURE_IMAGE_UNITS`. An eight-target shader may fail to link or the FBO may become invalid instead of selecting a fallback.
2. FBO completeness is checked when the primary framebuffer is bound, before the extra MRT attachments are added. There is no completeness check after the full eight-target set is assembled.
3. `SetMRTIndex` allocates a new heap array and calls `glDrawBuffers` for every attachment. Binding eight targets performs seven allocations and seven progressively larger draw-buffer updates per G-buffer pass.
4. MRT outputs must remain contiguous from zero. The converter stops scanning at the first missing `gl_FragData[n]`, so variants cannot leave holes in their output locations.
5. The OpenGL and D3D clear behavior differs. OpenGL `glClear` affects the active draw buffers, while the D3D `SetMRTIndex` implementation clears each secondary target as it is attached. Every target must be explicitly initialized by the render graph rather than relying on attachment side effects.
6. Texture-coordinate Y handling and clip-space reconstruction differ between the generated GLSL and HLSL paths. The deferred sun shader should reuse the existing shared depth-unpack and position-reconstruction conventions and receive explicit TAA inverse data; it should not introduce a D3D-only UV flip.

A production-quality cross-API implementation therefore needs a small CppProject capability layer even though the rendering algorithm itself can be driven from GML. At startup it should query the three limits above, expose them to GML, validate the completed MRT framebuffer in debug builds, and select an appropriate shader variant.

## Memory and bandwidth cost

The parity-oriented layout is expensive for integrated graphics because the current normal surface is RGBA32F while the other seven proposed targets are RGBA8. Its color storage alone is 44 bytes per pixel.

| G-buffer storage | 1920×1080 | 3840×2160 |
|---|---:|---:|
| Eight color targets | ~87 MiB | ~348 MiB |
| Colors + one D24S8 buffer | ~95 MiB | ~380 MiB |
| Colors + eight D24S8 buffers | ~150 MiB | ~601 MiB |
| Compact RGBA8 normals + one D24S8 | ~71 MiB | ~285 MiB |

These figures exclude cascade and local-light shadow maps, the two HDR lighting targets, post-processing surfaces, ray-tracing buffers, and accumulation surfaces. On an integrated GPU, all of them compete with the CPU and application for shared memory bandwidth.

Only MRT 0 needs a depth/stencil allocation. Calling `surface_require` with its default `depth = true` for all eight surfaces would waste roughly 55 MiB at 1080p or 221 MiB at 4K. Secondary G-buffer surfaces should be created with `depth = false`. Because `surface_require` only applies the depth/HDR flags when first creating a surface, switching layouts must free and recreate surfaces rather than merely resizing them: [surface_require.gml (line 8)](../GmProject/scripts/surface_require/surface_require.gml#L8).

One geometry pass does not automatically mean less pixel bandwidth. The merged pass writes every enabled target for every surviving fragment, and the fullscreen sun pass then reads most of those targets before writing two RGBA32F lighting results. Heavy overdraw multiplies the G-buffer write cost. The old renderer repeats vertex work and material sampling, but its individual passes write narrower target sets. A bandwidth-limited integrated GPU can therefore regress even while CPU time and vertex processing improve.

## Expected performance by workload

| Workload | Likely result |
|---|---|
| Many objects/draw calls; CPU or vertex bound | Strong improvement from removing repeated `render_world` traversal and geometry submissions |
| OpenGL below 4.3 | Potentially larger CPU benefit because object SSBO batching is disabled, but higher compatibility risk |
| High resolution with modest geometry | Possible regression because MRT writes and fullscreen G-buffer reads dominate |
| Heavy foliage, particles, or layered alpha-hashed geometry | Possible regression from multiplied overdraw across all MRTs |
| SSS, SSAO, reflections, and indirect lighting enabled | Better amortization because those effects already need most G-buffer data |
| Effects disabled or low render settings | Full eight-target G-buffer is wasteful; compact or forward rendering is preferable |
| Accumulated multi-sample render | Any per-sample bandwidth penalty is multiplied by the requested sample count |

The OpenGL path below 4.3 disables object batching when SSBO support is unavailable: [ShaderLoadOpenGL.cpp (line 11)](../CppProject/Asset/ShaderLoadOpenGL.cpp#L11). Reducing three or four scene traversals to one is especially valuable there, but it does not remove the cost of each individual draw in the remaining G-buffer pass.

## Recommended rendering profiles

The eight-target layout should be a high-fidelity profile, not the only deferred layout.

### Full deferred

Use on capable discrete GPUs or when all high-quality effects are active:

- Eight MRTs with complete per-pixel SSS data.
- Fullscreen deferred sun.
- Deferred or light-volume local lighting.
- Existing separate glint pass.

### Compact deferred

Prefer on integrated GPUs:

- Five core targets: diffuse, depth, compact normal, material/F0, and emissive/flags.
- Store SSAO and scene flags in otherwise unused alpha channels.
- Do not allocate SSS radius/color targets when SSS is disabled.
- Use RGBA8 octahedral normals instead of RGBA32F. This can be implemented with shader and GML surface changes; adding R16G16_SNORM or another purpose-specific format would require CppProject framebuffer-format support.
- Keep uncommon SSS materials on an optional extra path, or use a lower-cost global SSS approximation.

### Legacy forward

Retain the existing path when:

- The driver exposes insufficient MRT or fragment-sampler limits.
- The deferred shader or assembled FBO fails validation.
- Non-alpha-hashed transparency or special blend modes dominate the scene.
- A short startup or cached benchmark shows that the compact/full deferred path is slower on the current adapter.

Shader variants should omit unused outputs entirely. Writing black to an attached but unused SSS or mask surface still consumes bandwidth.

## Implementation safeguards

1. Add `render_deferred_supported`, `render_deferred_profile`, maximum MRT count, and maximum fragment sampler count to the GML-visible renderer state.
2. Select full, compact, or legacy rendering once per device/settings configuration. Avoid changing attachment count every frame.
3. Allocate a depth buffer only for MRT 0 and recreate surfaces when the profile changes.
4. Pack normals into RGBA8 before enabling the full layout by default on integrated adapters; the existing RGBA32F normal target is the largest single G-buffer attachment.
5. Skip material, normal, and SSS targets when no enabled effect consumes them. In particular, do not force the full G-buffer merely because the high-quality renderer is active.
6. Render opaque and alpha-hashed objects front-to-back to reduce expensive G-buffer overdraw. Profile an optional depth prepass for foliage-heavy scenes; two cheap geometry passes can outperform one eight-target pass when overdraw is extreme.
7. Keep true alpha-blended and special-blend objects in a forward pass.
8. Replace the OpenGL per-index MRT API with one bulk bind that uses a fixed array, calls `glDrawBuffers` once, and validates the final FBO.
9. Cache static shadow maps and reduce shadow resolution before lowering G-buffer resolution. Shadow regeneration remains a major cost that deferred lighting does not remove.
10. Preserve the existing low-quality forward renderer as the guaranteed low-end path.

## Tiled lighting on OpenGL

A true tiled or clustered light-list builder should be optional on OpenGL. The current GL 4.3 path has SSBO support and could support a compute-based implementation after adding compute dispatch, image/UAV barriers, and light-list resources to CppProject. The GLSL 1.50 fallback cannot use the same implementation.

For older OpenGL and integrated devices, deferred light volumes or CPU-computed screen-space scissor rectangles are a safer intermediate step. They consume the shared compact G-buffer without requiring compute shaders or large per-tile buffers. The sun remains a single fullscreen pass in every profile.

Overall, deferred sun lighting is still a sound architectural direction, but an unconditional eight-MRT implementation would optimize for draw/vertex-bound discrete GPUs at the expense of some integrated systems. Capability-driven full/compact/legacy profiles are necessary for a portable performance improvement.
