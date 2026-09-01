/// render_done()

function render_done()
{
	draw_set_color(render_prev_color)
	draw_set_alpha(render_prev_alpha)
	camera_apply(cam_window)
	
	if (benchmark_mode)
	{
		var elapsed = get_timer() - render_start_time
		var surfaceelapsed = benchmark_surface_total_time - render_start_surface_time
		benchmark_render_total_time += elapsed - surfaceelapsed
	}
	
	return render_target
}
