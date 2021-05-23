/// shader_high_reflections_set(depthsurface, normalsurface, normalsurface2, diffusesurf, materialsurf)
/// @arg depthsurface
/// @arg normalsurface
/// @arg normalsurface2
/// @arg diffusesurf
/// @arg materialsurf

function shader_high_reflections_set(depthsurface, normalsurface, normalsurface2, diffusesurf, materialsurf)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurface))
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(normalsurface))
	texture_set_stage(sampler_map[?"uNormalBufferExp"], surface_get_texture(normalsurface2))
	texture_set_stage(sampler_map[?"uDiffuseBuffer"], surface_get_texture(diffusesurf))
	texture_set_stage(sampler_map[?"uMaterialBuffer"], surface_get_texture(materialsurf))
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_surf))
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	
	render_set_uniform("uNoiseSize", render_sample_noise_size)
	render_set_uniform("uNear", cam_near)
	render_set_uniform("uFar", cam_far)
	render_set_uniform("uProjMatrix", proj_matrix)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	render_set_uniform("uViewMatrix", view_proj_matrix)
	render_set_uniform("uViewMatrixInv", matrix_inverse(view_proj_matrix))
	
	render_set_uniform("uOffset", render_indirect_offset)
	
	if (app.setting_render_reflections_halfres)
		render_set_uniform_vec2("uScreenSize", ceil(render_width/2), ceil(render_height/2))
	else
		render_set_uniform_vec2("uScreenSize", render_width, render_height)
	
	render_set_uniform("uPrecision", app.setting_render_reflections_precision)
	render_set_uniform("uThickness", app.setting_render_reflections_thickness)
	render_set_uniform_color("uFallbackColor", render_background ? app.background_sky_color_final : c_black, 1)
	render_set_uniform("uFadeAmount", app.setting_render_reflections_fade_amount)
}
