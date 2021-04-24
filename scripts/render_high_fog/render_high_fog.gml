/// render_high_fog()

function render_high_fog()
{
	var resultsurf;
	
	render_surface[0] = surface_require(render_surface[0], render_width, render_height, true, true)
	resultsurf = render_surface[0]
	surface_set_target(resultsurf)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.HIGH_FOG)
		render_world_done()
	}
	surface_reset_target()
	
	return resultsurf
}
