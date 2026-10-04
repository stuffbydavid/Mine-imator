function render_world(mode)
{
	// Choose shader
	render_mode = mode
	render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
	
	with (render_shader_obj)
		shader_use()
	
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
		render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH &&
		render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH &&
		render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH)
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
	render_world_count++
}
