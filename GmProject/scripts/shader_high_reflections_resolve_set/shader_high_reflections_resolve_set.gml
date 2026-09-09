/// shader_high_reflections_resolve_set(surf)
/// @arg surf

function shader_high_reflections_resolve_set(surf)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_depth))
	gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
	
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(render_surface_material))
	gpu_set_texrepeat_ext(sampler_map[?"uMaterialBuffer"], false)
	
	texture_set_stage(sampler_map[?"uSceneBuffer"], surface_get_texture(surf))
	gpu_set_texrepeat_ext(sampler_map[?"uSceneBuffer"], false)
	
	texture_set_stage(sampler_map[?"uMetallicBuffer"], surface_get_texture(render_surface_diffuse))
	gpu_set_texrepeat_ext(sampler_map[?"uMetallicBuffer"], false)
	
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrixInv", matrix_inverse_ext(proj_matrix))
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform_vec2("uRayDataSize", surface_get_width(render_surface_raydata), surface_get_height(render_surface_raydata))
	render_set_uniform_color("uSkyColor", app.background_sky_color_final, 1)
	render_set_uniform("uFadeAmount", app.project_render_reflections_fade_amount)
	render_set_uniform("uGamma", render_gamma)
	render_set_uniform_int("uSampleAmount", array_length(render_raytrace_kernel) / 2)
	render_set_uniform("uSamples", render_raytrace_kernel)
}
