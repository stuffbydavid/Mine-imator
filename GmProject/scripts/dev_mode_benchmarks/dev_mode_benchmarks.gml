/// dev_mode_benchmarks()
/// Performs a sequence of benchmarks and saves the rendered results in the project folder under runs/, along with CSV tables of timing data.
function dev_mode_benchmarks()
{
	log("Benchmark project API", graphics_api_get())
	log("Benchmark project file", project_file)
	directory_create_lib(project_folder + "/runs")
	
	// Run the queued resource loaders without drawing their loading popup.
	while (popup_loading.load_script != null)
	{
		with (popup_loading.load_object)
			script_execute(app.popup_loading.load_script)
	}
	log("Benchmark project resources loaded")
	
	startup_error = false
	
	var presets, currentpreset, testlength;
	presets = array("low", "med", "high")
	currentpreset = 0
	testlength = 10
	
	benchmark_mode = true
	render_view_current = view_main
	render_particles = view_main.particles
	render_effects = view_main.effects
	render_hidden = false
	render_background = true
	render_watermark = false

	var benchmarkstarttime, curdatetime, curyear, curmonth, curday, foldername, testdirectory; 
	benchmarkstarttime = get_timer()
	curdatetime = date_current_datetime()
	curyear = date_get_year(curdatetime)
	curmonth = date_get_month(curdatetime)
	curday = date_get_day(curdatetime)
	foldername = string(curyear) + (curmonth < 10 ? "0" : "") + string(curmonth) + (curday < 10 ? "0" : "") + string(curday) + "_"
	foldername += string_replace_all(date_time_string(date_current_datetime()), ":", "") + "_"
	foldername += graphics_api_get()
	testdirectory = project_folder + "/runs/" + foldername
	directory_create_lib(testdirectory)
	
	action_project_render_import(project_folder + "/preset_" + presets[currentpreset] + ".mirender")
	log("Benchmark project samples", project_render_samples)
	project_changed = false
	
	var csv, csvfilename;
	csv = "Frame,Preset,Mode,Samples,Animate_ms,Total_ms,Render_ms,Surface_ms,Encode_ms,Other_ms\n"
	csvfilename = testdirectory + "/benchmark.csv"
	
	timeline_marker = 0
	timeline_marker_previous = -1
	
	while (true)
	{
		// Animate
		benchmark_animate_total_time = 0
		app_update_animate()
		csv += string(timeline_marker) + ",,,," + string_format(benchmark_animate_total_time / 1000, 0, 3) + ",,,\n"
		
		for (var quality_index = 0; quality_index < 3; quality_index++)
		{
			var quality, mode, samples;
			switch (quality_index)
			{
				case 0:
					mode = "flat"
					quality = e_view_mode.FLAT
					samples = 1
					break
				case 1:
					mode = "shaded"
					quality = e_view_mode.SHADED
					samples = 1
					break
				case 2:
					mode = "high"
					quality = e_view_mode.RENDER
					samples = project_render_samples
					break
			}
			
			log("Benchmark frame", timeline_marker, mode)

			popup_exportimage.high_quality = (quality = e_view_mode.RENDER)
			export_filename = testdirectory + "/" + string(timeline_marker) + "_" + mode + ".png"
			
			render_lights = (quality != e_view_mode.FLAT)
			
			benchmark_render_total_time = 0
			benchmark_surface_total_time = 0
			benchmark_encode_total_time = 0

			var starttime = get_timer()

			export_start("export_image")
			while (export_update()) {}

			var exporttime = get_timer() - starttime;
			var othertime = exporttime - benchmark_render_total_time - benchmark_encode_total_time
			
			csv += string(timeline_marker) + ","
			csv += presets[currentpreset] + ","
			csv += mode + ","
			csv += string(samples) + ",,"
			csv += string_format((exporttime + benchmark_animate_total_time) / 1000, 0, 3) + ","
			csv += string_format(benchmark_render_total_time / 1000, 0, 3) + ","
			csv += string_format(benchmark_surface_total_time / 1000, 0, 3) + ","
			csv += string_format(benchmark_encode_total_time / 1000, 0, 3) + ","
			csv += string_format(othertime / 1000, 0, 3) + "\n"
			
			log("Benchmark image", export_filename, string_format(exporttime / 1000, 0, 3) + " msec")
		}
			
		timeline_marker++
		if (timeline_marker >= timeline_length
			|| (testlength > 0 && timeline_marker >= testlength))
			break
	}

	var totaltime = get_timer() - benchmarkstarttime
	log("Benchmark complete", string_format(totaltime / 1000, 0, 3) + " msec")
	csv += "All," + string_format(totaltime / 1000, 0, 3) + ",,,,,"
	
	var f = file_text_open_write(temp_file);
	if (f > -1)
	{
		file_text_write_string(f, csv)
		file_text_close(f)
		file_copy_lib(temp_file, csvfilename)
	}
	
	if (is_cpp())
		file_copy_lib(log_file_get(), testdirectory + "/log.txt")
	
	game_end()
	return true
}
