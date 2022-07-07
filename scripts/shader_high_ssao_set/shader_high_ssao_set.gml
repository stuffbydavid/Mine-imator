/// shader_high_ssao_set(depthsurface, normalsurface, emissivesurf)
/// @arg depthsurface
/// @arg normalsurface
/// @arg emissivesurf

function shader_high_ssao_set(depthsurface, normalsurface, emissivesurf)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(depthsurface))
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(normalsurface))
	texture_set_stage(sampler_map[?"uEmissiveBuffer"], surface_get_texture(emissivesurf))
	texture_set_stage(sampler_map[?"uNoiseBuffer"], surface_get_texture(render_sample_noise_texture))
	gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uEmissiveBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uNoiseBuffer"], true)
	
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
	render_set_uniform("uProjMatrix", proj_matrix)
	render_set_uniform("uProjMatrixInv", matrix_inverse(proj_matrix))
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform("uNoiseSize", render_sample_noise_size)
	
	render_set_uniform("uKernel", render_ssao_kernel)
	render_set_uniform("uRadius", app.project_render_ssao_radius)
	render_set_uniform("uPower", app.project_render_ssao_power)
	render_set_uniform_color("uColor", app.project_render_ssao_color, 1)
}
