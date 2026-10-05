function shader_high_ssao_blur_set(checkx, checky)
{
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_depth))
	texture_set_stage(sampler_map[?"uNormalBuffer"], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_map[?"uDepthBuffer"], false)
	gpu_set_texrepeat_ext(sampler_map[?"uNormalBuffer"], false)
	
	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	render_set_uniform(e_uniform.PROJ_MATRIX_INV, matrix_inverse_ext(proj_matrix))
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform_vec2(e_uniform.PIXEL_CHECK, checkx, checky)
}
