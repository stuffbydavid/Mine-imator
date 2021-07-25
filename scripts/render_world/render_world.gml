/// render_world(mode)
/// @arg mode

function render_world(mode)
{
	// Choose shader
	render_mode = mode
	render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
	with (render_shader_obj)
		shader_use()
	
	shader_check_uniform = true
	
	var renderlistsize, tl;
	renderlistsize = ds_list_size(render_list)
	
	render_world_tl_reset()
	
	// Render negative depth
	var i;
	for (i = 0; i < renderlistsize; i++)
	{
		tl = render_list[|i]
		
		if (tl.depth >= 0)
			break
		
		with (tl)
			render_world_tl()
	}
	
	render_world_tl_reset()
	
	// Neutral depth (0)
	if (render_mode != e_render_mode.CLICK &&
		render_mode != e_render_mode.SELECT &&
		render_mode != e_render_mode.HIGH_LIGHT_SUN_DEPTH &&
		render_mode != e_render_mode.HIGH_LIGHT_SPOT_DEPTH &&
		render_mode != e_render_mode.HIGH_LIGHT_POINT_DEPTH &&
		render_mode != e_render_mode.ALPHA_TEST)
	{
		if (render_mode = e_render_mode.SCENE_TEST)
			render_set_uniform_color("uReplaceColor", c_white, 1)
		
		render_world_ground()
		render_world_sky_clouds()
		render_world_tl_reset()
	}
	
	// Positive depth
	for (; i < renderlistsize; i++)
		with (render_list[|i])
			render_world_tl()
	
	render_world_tl_reset()
	
	with (render_shader_obj)
		shader_clear()
	
	if (gpu_get_tex_filter())
		gpu_set_tex_filter(false)
	
	shader_check_uniform = false
}
