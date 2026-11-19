function app_startup_interface_export()
{
	export_surface = null
	
	export_sample = 0
	export_sample_rate_start = 0
	export_sample_rate_count = 0
	export_samples_per_second = 0
	export_filename = ""
	
	export_escape_time = 0
	export_render_time = 0
	
	exportmovie_format = ""
	exportmovie_marker_previous = 0
	exportmovie_marker_start = 0
	exportmovie_marker_end = 0
	exportmovie_frame = 0
	exportmovie_frame_rate = 0
	exportmovie_framespersecond = 0
	exportmovie_renderer = e_renderer.REALISTIC
	exportmovie_start = null
	exportmovie_buffer = null
	exportmovie_benchmark_csv = ""
	
	render_depth_list = null
	render_list_update = true
	render_list_camera_from = null
	render_world_bounds = null
	render_world_bounds_id = -1
	render_world_visible = []
	render_world_visible_count = 0
}
