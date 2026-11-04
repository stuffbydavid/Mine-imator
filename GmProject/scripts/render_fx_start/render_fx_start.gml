/// @arg basesurface
/// @arg [hdr]

function render_fx_start(prevsurf, hdr = false)
{
	var basesurf;
	
	// Continue ping-pong from the input surface after effects are refreshed
	if (hdr)
		render_fx_index = (prevsurf = render_surface_hdr[0])
	else if (render_gbuffers_cache_enabled || renderer_current = e_renderer.QUICK)
		render_fx_index = (prevsurf = render_surface_post[0])
	else
		render_fx_index = (prevsurf = render_surface_material)
	
	// Are there any post processing effects?
	render_fx_progress = -1
	render_fx_update()
	
	// No effects left, return
	if (render_fx_done)
		return prevsurf

	basesurf = render_high_get_apply_surface(hdr)
	
	surface_set_target(basesurf)
	{
		draw_clear_alpha(c_black, 0)
		draw_surface_exists(prevsurf, 0, 0)
	}
	surface_reset_target()
	
	render_fx_update()
	
	// Initialize lens surface if needed
	if (render_camera_lens_dirt && !render_fx_done)
	{
		render_surface_lens = surface_require(render_surface_lens, render_width, render_height, false, surface_rgba16float)
		
		surface_clear(render_surface_lens, c_black)
	}
	
	return basesurf
}
