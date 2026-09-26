/// export_start(state)
function export_start(state)
{
	window_state = state
	
	export_surface = null
	export_sample = 0
	
	render_samples = -1
	
	if (view_main.quality = e_view_mode.RENDER)
		view_main.quality = e_view_mode.SHADED
	
	if (view_second.quality = e_view_mode.RENDER)
		view_second.quality = e_view_mode.SHADED
}