/// @arg surface

function shader_high_reflections_resolve_set(surf)
{
	texture_set_stage(sampler_handle[e_sampler.DEPTH_BUFFER], surface_get_texture(render_surface_depth))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.DEPTH_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.NORMAL_BUFFER], surface_get_texture(render_surface_normal))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.NORMAL_BUFFER], false)

	texture_set_stage(sampler_handle[e_sampler.MATERIAL_BUFFER], surface_get_texture(render_surface_material))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.MATERIAL_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.SCENE_BUFFER], surface_get_texture(surf))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.SCENE_BUFFER], false)
	
	texture_set_stage(sampler_handle[e_sampler.METALLIC_BUFFER], surface_get_texture(render_surface_diffuse))
	gpu_set_texrepeat_ext(sampler_handle[e_sampler.METALLIC_BUFFER], false)

	render_set_uniform(e_uniform.NEAR, depth_near)
	render_set_uniform(e_uniform.FAR, depth_far)
	render_set_uniform(e_uniform.PROJ_MATRIX_INV, matrix_inverse_ext(proj_matrix))
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform_vec2(e_uniform.RAY_DATA_SIZE, surface_get_width(render_surface_reflections_raydata), surface_get_height(render_surface_reflections_raydata))
	render_set_uniform_color(e_uniform.SKY_COLOR, app.env_sky_color_final, 1)
	render_set_uniform_color(e_uniform.FOG_COLOR, app.env_fog_color_final, 1)
	render_set_uniform(e_uniform.FADE_AMOUNT, app.project_render_reflections_fade_amount)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
	render_set_uniform(e_uniform.RAY_DISTANCE, min(3000, depth_far))
	render_set_uniform(e_uniform.BACKGROUND_BRIGHTNESS, app.env_brightness)
	render_set_uniform_int(e_uniform.SAMPLE_AMOUNT, app.project_render_reflections_resolution < 1 ? array_length(render_raytrace_kernel) / 2 : 1)
	render_set_uniform(e_uniform.SAMPLES, render_raytrace_kernel)
}
