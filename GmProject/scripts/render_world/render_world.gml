function render_world(mode)
{
	// Choose shader
	render_mode = mode

	// The lightweight auxiliary shader also needs emissive material values
	render_material_pass = true
	
	render_depth_pass = (
		mode = e_render_mode.DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_SUN_DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH ||
		mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH
	)
	// Scene tests need full color and fog setup for the premultiplied lighting mask
	render_fast_pass = (
		render_depth_pass ||
		mode = e_render_mode.CLICK ||
		mode = e_render_mode.SELECT ||
		mode = e_render_mode.PLACE_SELECT ||
		mode = e_render_mode.PLACE_PARENT
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
	else if (mode = e_render_mode.AUXILIARY && !render_auxiliary_material)
		render_shader_obj = shader_map[?shader_high_auxiliary_standard]
	else
		render_shader_obj = shader_map[?render_mode_shader_map[?mode]]

	with (render_shader_obj)
		shader_use()
	
	if (mode = e_render_mode.AUXILIARY && !render_auxiliary_material)
		render_set_uniform_int(e_uniform.GLOW_PASS, render_glow)
	
	shader_check_uniform = true
	render_world_block_transparent = (render_depth_pass ? null : false)
	
	render_world_tl_reset()
	
	// Rebuild compact timeline ID list for placing
	if (render_place_tl_list = null)
		render_place_tl_list_update()
	
	// Simple render
	if (mode = e_render_mode.PLACE_PARENT)
		render_world_list(0)
	else
	{
		// Negative depth objects
		render_world_list(-1)
		
		// Neutral depth ground and clouds
		render_world_environment()
		
		// Neutral and positive depth objects
		render_world_list(0)
		render_world_list(1)
	}
	
	render_world_block_transparent = null

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
