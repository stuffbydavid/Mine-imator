/// shader_high_volumetric_rays_set(depth, sundepth)
/// @arg depth
/// @arg sundepth

render_set_uniform("uNear", cam_near)
render_set_uniform("uFar", cam_far)

render_set_uniform("uLightNear", render_light_near)
render_set_uniform("uLightFar", render_light_far)

render_set_uniform("uScattering", app.background_volumetric_rays_scatter)
render_set_uniform("uDensity", app.background_volumetric_rays_density)

render_set_uniform_color("uColor", app.background_volumetric_rays_color, 1)
render_set_uniform_color("uSunColor", app.background_sunlight_color_final, 1)
render_set_uniform_color("uEmissiveColor", app.background_volumetric_rays_emissive, 1)

render_set_uniform("uSunMatrix", render_sun_matrix)
render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
render_set_uniform("uViewMatrixInv", matrix_inverse(view_matrix))

render_set_uniform_vec3("uSunDirection", render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])

texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(argument0))
gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], false)

texture_set_stage(sampler_map[?"uSunDepthBuffer"], surface_get_texture(argument1))
gpu_set_texfilter_ext(sampler_map[?"uSunDepthBuffer"], true)

render_set_uniform_vec3("uCameraPosition", cam_from[X], cam_from[Y], cam_from[Z])