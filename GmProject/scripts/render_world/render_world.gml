function render_world(mode)
{
	// Choose shader
	render_mode = mode

	render_material_pass = (mode != e_render_mode.AUXILIARY || render_auxiliary_material)
	
	render_depth_pass = (
		mode = e_render_mode.DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_SUN_DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH
	)
	
	render_fast_pass = (
		render_depth_pass ||
		mode = e_render_mode.CLICK ||
		mode = e_render_mode.SELECT ||
		mode = e_render_mode.PLACE_SELECT ||
		mode = e_render_mode.PLACE_PARENT ||
		mode = e_render_mode.SCENE_TEST
	)

	if (render_place)
	{
		render_place_pass = (
			mode = e_render_mode.COLOR_FOG ||
			mode = e_render_mode.COLOR_FOG_LIGHTS ||
			mode = e_render_mode.G_BUFFERS ||
			(mode = e_render_mode.COLOR && render_color_combined)
		)
	}
	else
		render_place_pass = false

	// Select shader object
	if (mode = e_render_mode.COLOR && render_color_combined)
		render_shader_obj = shader_map[?shader_high_gbuffers_color]
	else if (mode = e_render_mode.G_BUFFERS && render_sun_combined)
		render_shader_obj = shader_map[?shader_high_gbuffers_sun]
	else if (!render_material_pass)
		render_shader_obj = shader_map[?shader_high_auxiliary_standard]
	else
		render_shader_obj = shader_map[?render_mode_shader_map[?mode]]

	with (render_shader_obj)
		shader_use()
	
	if (!render_material_pass)
		render_set_uniform_int(e_uniform.GLOW_PASS, render_glow)
	
	shader_check_uniform = true
	render_world_blocks_transparent = (render_depth_pass ? null : false)
	
	render_world_tl_reset()
	
	// Placed parent
	if (mode = e_render_mode.PLACE_PARENT)
		render_world_list(render_place_parent_list)
	
	// Order-independent render
	else if (render_fast_pass)
	{
		render_world_environment()
		render_world_list(app.project_timeline_list)
	}
	else
	{
		// Negative depth objects
		render_world_list(render_depth_list_current[e_depth_list.NEGATIVE])
		
		// Ground and clouds
		render_world_environment()
		
		// Default opaque objects and neutral depth
		render_world_list(render_list_default)
		
		// Positive depth objects
		render_world_list(render_depth_list_current[e_depth_list.POSITIVE])
	}
	
	render_world_blocks_transparent = null

	render_world_tl_reset()
	
	with (render_shader_obj)
		shader_clear()
	
	if (gpu_get_tex_filter())
		gpu_set_tex_filter(false)
	
	shader_check_uniform = false
	render_fast_pass = false
	render_depth_pass = false
	render_place_pass = false
	render_world_count++
}
