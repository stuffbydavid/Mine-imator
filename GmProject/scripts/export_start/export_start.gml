/// export_start(state)
function export_start(state)
{
	window_state = state
	
	export_surface = null
	export_sample = 0
	
	render_samples = -1
	
	if (view_main.renderer = e_renderer.REALISTIC)
		view_main.renderer = e_renderer.STANDARD
	
	if (view_second.renderer = e_renderer.REALISTIC)
		view_second.renderer = e_renderer.STANDARD
	
	benchmark_animate_total_time = 0
	benchmark_render_total_time = 0
	benchmark_surface_total_time = 0
	benchmark_export_total_time = 0
}
