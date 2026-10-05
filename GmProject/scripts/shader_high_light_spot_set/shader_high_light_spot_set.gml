function shader_high_light_spot_set()
{
	render_set_uniform(e_uniform.EMISSIVE, 0)
	
	render_set_uniform_int(e_uniform.IS_SKY, 0)
	render_set_uniform_int(e_uniform.IS_WATER, 0)
	
	render_set_uniform(e_uniform.LIGHT_MATRIX, render_spot_matrix)
	render_set_uniform(e_uniform.SHADOW_MATRIX, render_shadow_matrix)
	render_set_uniform_vec3(e_uniform.LIGHT_POSITION, render_light_from[X], render_light_from[Y], render_light_from[Z])
	render_set_uniform_color(e_uniform.LIGHT_COLOR, render_light_color, 1)
	render_set_uniform(e_uniform.LIGHT_STRENGTH, render_light_strength)
	render_set_uniform(e_uniform.LIGHT_SPECULAR, render_light_specular_strength)
	render_set_uniform(e_uniform.LIGHT_SIZE, render_light_size)
	
	var shadowscale = 1 / max(2 * tan((render_light_fov / 57.2958) * .5), .0001);
	render_set_uniform(e_uniform.SHADOW_RADIUS, render_light_size * .5 * app.project_render_shadows_blur_size * shadowscale)
	render_set_uniform_int(e_uniform.SHADOW_BLUR_QUALITY, app.project_render_shadows_jittered ? 0 : app.project_render_shadows_blur_quality)
	render_set_uniform(e_uniform.PCSS_KERNEL, render_pcss_kernel_rotated)
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
	
	render_set_uniform(e_uniform.LIGHT_NEAR, render_light_near)
	render_set_uniform(e_uniform.LIGHT_FAR, render_light_far)
	render_set_uniform(e_uniform.LIGHT_FADE_SIZE, render_light_fade_size)
	render_set_uniform_int(e_uniform.LIGHT_REALISTIC_FALLOFF, render_light_realistic_falloff)
	render_set_uniform(e_uniform.LIGHT_SPOT_SHARPNESS, render_light_spot_sharpness)
	
	texture_set_stage(sampler_map[?"uDepthBuffer"], surface_get_texture(render_surface_spot_buffer))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer"], true)
}
