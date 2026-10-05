function shader_high_light_sun_set()
{
	render_set_uniform(e_uniform.EMISSIVE, 0)

	render_set_uniform_int(e_uniform.IS_GROUND, 0)
	render_set_uniform_int(e_uniform.IS_SKY, 0)
	render_set_uniform_int(e_uniform.IS_WATER, 0)

	var cascade1 = render_cascades[render_cascades_count > 1 ? 1 : 0];
	var cascade2 = render_cascades[render_cascades_count > 2 ? 2 : render_cascades_count - 1];
	render_set_uniform_mat4_array(e_uniform.LIGHT_MAT_BIAS_MVP, [ render_cascades[0].matBias, cascade1.matBias, cascade2.matBias ])

	render_set_uniform(e_uniform.SUN_NEAR, [ render_cascades[0].near, cascade1.near, cascade2.near ])
	render_set_uniform(e_uniform.SUN_FAR, [ render_cascades[0].far, cascade1.far, cascade2.far ])
	render_set_uniform(e_uniform.CASCADE_WORLD_SIZE, [ render_cascades[0].worldSize, cascade1.worldSize, cascade2.worldSize ])
	render_set_uniform_color(e_uniform.LIGHT_COLOR, render_light_color, 1)
	render_set_uniform(e_uniform.LIGHT_STRENGTH, render_light_strength)
	render_set_uniform(e_uniform.LIGHT_SPECULAR, render_light_specular_strength)
	render_set_uniform(e_uniform.SUN_ANGULAR_RADIUS, tan(degtorad(min(app.env_sunlight_angle, 179)) * .5))
	render_set_uniform(e_uniform.GAMMA, render_gamma)
	render_set_uniform_int(e_uniform.SHADOW_BLUR_QUALITY, app.project_render_shadows_jittered ? 0 : app.project_render_shadows_blur_quality)
	render_set_uniform(e_uniform.PCSS_KERNEL, render_pcss_kernel_rotated)
	render_set_uniform(e_uniform.SUN_SHADOW_SCALE, render_sun_shadow_scale)
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)

	render_set_uniform_vec3(e_uniform.LIGHT_DIRECTION, render_sun_direction[X], render_sun_direction[Y], render_sun_direction[Z])
	
	texture_set_stage(sampler_map[?"uDepthBuffer0"], surface_get_texture(render_surface_sun_buffer[0]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer0"], true)
	
	texture_set_stage(sampler_map[?"uDepthBuffer1"], surface_get_texture(render_surface_sun_buffer[render_cascades_count > 1 ? 1 : 0]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer1"], true)
	
	texture_set_stage(sampler_map[?"uDepthBuffer2"], surface_get_texture(render_surface_sun_buffer[render_cascades_count > 2 ? 2 : render_cascades_count - 1]))
	gpu_set_texfilter_ext(sampler_map[?"uDepthBuffer2"], true)
	
	render_set_uniform(e_uniform.CASCADE_END_CLIP_SPACE, [ render_cascades[0].clipEndDepth, cascade1.clipEndDepth, cascade2.clipEndDepth ])
	render_set_uniform_int(e_uniform.CASCADE_COUNT, render_cascades_count)
}
