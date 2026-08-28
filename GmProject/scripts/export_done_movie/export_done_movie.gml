/// export_done_movie()

function export_done_movie()
{
	render_free()
	
	if (exportmovie_format != "png")
	{
		movie_done()
		buffer_delete(exportmovie_buffer)
	}
	
	surface_free(export_surface)
	export_surface = null
	window_state = ""
	
	window_taskbar_progress_state_set()
	
	render_watermark = false
	render_background = true
	render_hidden = false
	
	timeline_marker = exportmovie_marker_previous
	
	var fn;
	if (exportmovie_format = "png")
		fn = filename_new_ext(export_filename, "") + "_1.png"
	else
		fn = export_filename
		
	if (dev_mode_exportmovie_benchmarks)
	{
		var totaltime = get_timer() - exportmovie_start;
		exportmovie_benchmark_csv += "All_ms," + string_format(totaltime / 1000, 0, 3)
	
		var f = file_text_open_write(temp_file);
		if (f > -1)
		{
			file_text_write_string(f, exportmovie_benchmark_csv)
			file_text_close(f)
			file_copy_lib(temp_file, export_filename + ".csv")
		}
		exportmovie_benchmark_csv = ""
		benchmark_mode = false
	}
	
	toast_new(e_toast.POSITIVE, text_get("alertexportmovie"))
	toast_add_action("alertexportmovieview", popup_open_url, fn)
	toast_last.dismiss_time = 10
}
