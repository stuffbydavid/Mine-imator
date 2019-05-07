/// render_high_post_start(basesurf)
/// @arg basesurf

var basesurf = argument0;

if (!render_effects_done)
{
	var prevsurf = basesurf;
	render_surface_post[0] = surface_require(render_surface_post[0], render_width, render_height)
	basesurf = render_surface_post[0]
	render_post_index = !render_post_index
	
	surface_set_target(basesurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(prevsurf, 0, 0)
	}
	surface_reset_target()
}
render_update_effects()

// Initialize lens surface if needed
if (render_camera_lens_dirt)
{
	render_surface_lens = surface_require(render_surface_lens, render_width, render_height)
	
	surface_set_target(render_surface_lens)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
}
