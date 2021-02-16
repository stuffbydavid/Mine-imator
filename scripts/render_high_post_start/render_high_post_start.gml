/// render_high_post_start(basesurf)
/// @arg basesurf

var prevsurf, basesurf;
prevsurf = argument0

// Are there any post processing effects?
render_effects_progress = -1
render_update_effects()

basesurf = render_high_get_apply_surf()

surface_set_target(basesurf)
{
	draw_clear_alpha(c_black, 0)
	draw_surface_exists(prevsurf, 0, 0)
}
surface_reset_target()

render_update_effects()

// Initialize lens surface if needed
if (render_camera_lens_dirt && !render_effects_done)
{
	render_surface_lens = surface_require(render_surface_lens, render_width, render_height)
	
	surface_set_target(render_surface_lens)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
}

return basesurf