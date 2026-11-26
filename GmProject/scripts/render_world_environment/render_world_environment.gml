function render_world_environment()
{
	if (render_mode = e_render_mode.CLICK ||
		render_mode = e_render_mode.SELECT ||
		render_mode = e_render_mode.PLACE_SELECT ||
		(render_depth_pass && render_mode != e_render_mode.DEPTH))
		return 0
	
	render_world_tl_reset()
	
	render_world_ground()
	render_world_sky_clouds()
	
	render_world_tl_reset()
}