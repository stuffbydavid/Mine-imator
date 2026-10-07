function render_world(mode)
{
	// Choose shader
	render_mode = mode
	render_material_pass = (mode != e_render_mode.AUXILIARY || render_auxiliary_material)
	
	if (mode = e_render_mode.COLOR && render_color_combined)
		render_shader_obj = shader_map[?shader_high_gbuffers_color]
	else if (mode = e_render_mode.G_BUFFERS && render_sun_combined)
		render_shader_obj = shader_map[?shader_high_gbuffers_sun]
	else if (!render_material_pass)
		render_shader_obj = shader_map[?shader_high_auxiliary_standard]
	else
		render_shader_obj = shader_map[?render_mode_shader_map[?mode]]
	
	render_depth_pass = (
		mode = e_render_mode.DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_SUN_DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH
	)
	
	with (render_shader_obj)
		shader_use()
	
	if (!render_material_pass)
		render_set_uniform_int(e_uniform.GLOW_PASS, render_glow)
	
	shader_check_uniform = true
	render_world_block_transparent = false
	
	render_world_tl_reset()
	
	if (render_list_depth_dirty)
	{
		var listsize, boundary;
		listsize = ds_list_size(render_list)
		boundary = 0

		while (boundary < listsize && render_list[|boundary].depth < 0)
			boundary++
		
		render_list_depth_bounds[1] = boundary

		while (boundary < listsize && render_list[|boundary].depth = 0)
			boundary++
		
		render_list_depth_bounds[2] = boundary

		render_list_depth_bounds[3] = listsize
		render_list_depth_dirty = false
	}

	// Negative depth objects
	render_world_list(-1)
	
	// Neutral depth ground and clouds
	if (render_mode != e_render_mode.CLICK &&
		render_mode != e_render_mode.SELECT &&
		render_mode != e_render_mode.PLACE_SELECT &&
		render_mode != e_render_mode.PLACE_PARENT &&
		(!render_depth_pass || mode = e_render_mode.DEPTH))
	{
		render_world_tl_reset()
		render_world_ground()
		
		if (render_mode != e_render_mode.PLACE)
			render_world_sky_clouds()
		
		render_world_tl_reset()
	}
	
	// Neutral and positive depth objects
	render_world_list(0)
	render_world_list(1)
	
	render_world_block_transparent = null
	
	// Build box
	if (app.place_build)
		render_world_build_box()

	render_world_tl_reset()
	
	with (render_shader_obj)
		shader_clear()
	
	if (gpu_get_tex_filter())
		gpu_set_tex_filter(false)
	
	shader_check_uniform = false
	render_depth_pass = false
	render_world_count++
}
