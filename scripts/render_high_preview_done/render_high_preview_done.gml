/// render_high_preview_done()

function render_high_preview_done()
{
	if (!render_high_preview)
		return 0
	
	render_width = render_high_preview_width
	render_height = render_high_preview_height
		
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	var tempsurf = render_surface[0];
		
	surface_set_target(tempsurf)
	{
		draw_clear_alpha(c_black, 1)
		draw_surface_ext(render_target, 0, 0, 2, 2, 0, c_white, 1)
	}
	surface_reset_target()
		
	render_target = surface_require(render_target, render_width, render_height)
	surface_set_target(render_target)
	{
		draw_clear_alpha(c_black, 1)
		draw_surface(tempsurf, 0, 0)
	}
	surface_reset_target()
}