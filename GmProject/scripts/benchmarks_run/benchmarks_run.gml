/// benchmarks_run()
/// @desc Performs a sequence of benchmarks and saves the rendered results in the project folder under runs/, along with CSV tables of timing data.
///		  Render settings are overwritten during playback by text keyframes. A render mode is skipped entirely if the keyframe is invisible.

function benchmarks_run()
{
	var teststart, testend, testfull, exportpasses, showdragons;
	teststart = 0
	testend = 10
	testfull = false
	exportpasses = false
	showdragons = true
	
	// Overwrite defaults by program arguments
	if (benchmark_start > -1)
		teststart = benchmark_start
	if (benchmark_end > -1)
		testend = benchmark_end
	if (benchmark_full)
		testfull = true
	if (benchmark_exportpasses)
		exportpasses = true
		
	log("Benchmark project API", graphics_api_get())
	log("Benchmark project file", project_file)
	log("Benchmark project start", teststart)
	log("Benchmark project end", testfull ? timeline_length : testend)
	
	// Run the queued resource loaders without drawing their loading popup
	while (popup_loading.load_script != null)
	{
		with (popup_loading.load_object)
			script_execute(app.popup_loading.load_script)
	}
	startup_error = false
	log("Benchmark project resources loaded")
	
	// Load base render preset, to be overwritten by text keyframes
	var mirenderfile, mirenderobj;
	mirenderfile = project_folder + "/benchmark_base.mirender"
	mirenderobj = new_obj(obj_history_save)
	if (file_exists_lib(mirenderfile))
		action_project_render_import(mirenderfile)
	
	with (mirenderobj)
		history_copy_render_settings(app)
	
	// Optionally test a large number of (hopefully batched) models
	with (obj_timeline)
		if (parent != app && string_contains(parent.name, "Dragons"))
			hide = !showdragons
	
	render_view_current = view_main
	render_particles = view_main.particles
	render_effects = view_main.effects
	render_hidden = false
	render_background = true
	render_watermark = false

	var benchmarkstarttime, curdatetime, curyear, curmonth, curday, testname, testdir; 
	benchmarkstarttime = get_timer()
	curdatetime = date_current_datetime()
	curyear = date_get_year(curdatetime)
	curmonth = date_get_month(curdatetime)
	curday = date_get_day(curdatetime)
	testname = string(curyear) + (curmonth < 10 ? "0" : "") + string(curmonth) + (curday < 10 ? "0" : "") + string(curday) + "_"
	testname += string_replace_all(date_time_string(date_current_datetime()), ":", "")
	testname += "_" + graphics_api_get()
	testname += is_optimized()  ? "" : "_DEBUG"
	testdir = project_folder + "/runs/" + testname
	directory_create_lib(project_folder + "/runs")
	directory_create_lib(testdir)
	
	log("Benchmark project test folder", testdir)
	 
	var csv, csvfilename;
	csv = "Frame,Mode,Setting,Samples,Animate_ms,Total_ms,Render_ms,Surface_ms,Export_ms,Other_ms,render_world_calls,vertex_buffer_tris,vertex_buffer_submits\n"
	csvfilename = testdir + "/benchmark_" + testname + ".csv"
	
	timeline_marker = teststart
	timeline_marker_previous = teststart - 1
	
	while (true)
	{
		// Animate
		benchmark_animate_total_time = 0
		app_update_animate()
		csv += string(timeline_marker) + ",,,," + string_format(benchmark_animate_total_time / 1000, 0, 3) + ",,,,,,\n"
			
		for (var quality_index = 0; quality_index < 3; quality_index++)
		{
			var quality, mode;
			switch (quality_index)
			{
				case 0:
					mode = "flat"
					quality = e_view_mode.FLAT
					break
				case 1:
					mode = "shaded"
					quality = e_view_mode.SHADED
					break
				case 2:
					mode = "high"
					quality = e_view_mode.RENDER
					break
			}
			
			// Restore base settings
			history_copy_render_settings(mirenderobj)
			
			// Apply custom render settings one-by-one from text objects on the marker with a name matching the mode
			var settingsqueue, skipmode;
			settingsqueue = array()
			skipmode = false
			with (obj_timeline) {
				if (name != mode ||
					type != e_tl_type.TEXT)
					continue
					
				if (!value[e_value.VISIBLE])
				{
					skipmode = true
					continue
				}
					
				if (keyframe_current = null ||
					keyframe_current.position != app.timeline_marker ||
					keyframe_current.value[e_value.TEXT] = "")
					continue
				
				settingsqueue = string_split_escaped(keyframe_current.value[e_value.TEXT], "\n")
				break
			}
			
			// Skip mode for hidden keyframes
			if (skipmode)
				continue
			
			do
			{
				// Apply next setting in queue
				var cursetting, cursettingfn, exportbasename;
				cursetting = ""
				cursettingfn = ""
				if (array_length(settingsqueue) > 0)
				{
					cursetting = array_shift(settingsqueue)
					log("Benchmark frame", timeline_marker, mode, cursetting)
					benchmarks_apply_settings(cursetting)
					
					cursettingfn = "_" + string_replace_all(cursetting, "=", "_")
					cursettingfn = string_replace_all(cursettingfn, ",", "_")
				}
				else
					log("Benchmark frame", timeline_marker, mode)

				exportbasename = testdir + "/" + string(timeline_marker) + "_" + mode + cursettingfn
				export_filename = exportbasename + ".png"
			
				render_lights = (quality != e_view_mode.FLAT)
				popup_exportimage.high_quality = (quality = e_view_mode.RENDER)
			
				benchmark_render_total_time = 0
				benchmark_surface_total_time = 0
				benchmark_export_total_time = 0

				var starttime, exporttime, othertime;
				starttime = get_timer()
				
				// Render all samples
				export_start("export_image")
				while (export_update()) {}

				exporttime = get_timer() - starttime
				othertime = exporttime - benchmark_render_total_time - benchmark_export_total_time
			
				// Create CSV row with data
				csv += string(timeline_marker) + ","
				csv += mode + ","
				csv += string_replace_all(cursetting, ",", " ") + ","
				if (quality_index == 2)
					csv += string(project_render_samples) + ",,"
				else
					csv += "1,,"
				csv += string_format((exporttime + benchmark_animate_total_time) / 1000, 0, 3) + ","
				csv += string_format(benchmark_render_total_time / 1000, 0, 3) + ","
				csv += string_format(benchmark_surface_total_time / 1000, 0, 3) + ","
				csv += string_format(benchmark_export_total_time / 1000, 0, 3) + ","
				csv += string_format(othertime / 1000, 0, 3) + ","
				csv += string(render_world_count) + ","
				csv += string(get_vertex_buffer_triangles()) + ","
				csv += string(get_vertex_buffer_render_calls()) + "\n"
			
				log("Benchmark image", export_filename, string_format(exporttime / 1000, 0, 3) + " msec")
				if (exportpasses && quality = e_view_mode.RENDER)
					benchmarks_export_passes(exportbasename)
			}
			until (array_length(settingsqueue) = 0)
		}
			
		timeline_marker++
		if (timeline_marker >= timeline_length
			|| (!testfull && timeline_marker >= testend))
			break
	}

	// Save run data
	var totaltime = get_timer() - benchmarkstarttime
	log("Benchmark complete", string_format(totaltime / 1000, 0, 3) + " msec")
	csv += "All_ms," + string_format(totaltime / 1000, 0, 3)
	
	var f = file_text_open_write(temp_file);
	if (f > -1)
	{
		file_text_write_string(f, csv)
		file_text_close(f)
		file_copy_lib(temp_file, csvfilename)
	}
	
	if (is_cpp())
		file_copy_lib(log_file_get(), testdir + "/log.txt")
	
	game_end()
	return true
}

/// Exports the high-quality render passes for the current frame and render settings.
function benchmarks_export_passes(directory)
{
	var previouspass = project_render_pass;
	directory_create_lib(directory)

	for (var pass = e_render_pass.DIFFUSE; pass < e_render_pass.amount; pass++)
	{
		project_render_pass = pass
		export_filename = directory + "/" + ds_list_find_value(render_pass_list, pass) + ".png"

		var starttime;
		starttime = get_timer()
		export_start("export_image")
		while (export_update()) {}
		
		log("Benchmark render pass", export_filename, string_format((get_timer() - starttime) / 1000, 0, 3) + " msec")
	}

	project_render_pass = previouspass
}

/// Applies a number of comma-separated settings from a text line (setting1=-1,setting2=false).
function benchmarks_apply_settings(line)
{
	var settings = string_split_escaped(line, ",");
	for (var s = 0; s < array_length(settings); s++)
	{
		var setting, name, val;
		setting = string_split_escaped(settings[s], "=")
		if (array_length(setting) < 2) {
			log("Malformed setting at " + string(timeline_marker), settings[s])
			continue
		}
		
		name = string_replace(setting[0], "render_", "")
		if (setting[1] == "true")
			val = true
		else if (setting[1] == "false")
			val = false
		else
			val = eval(setting[1], 0)
		
		switch (name) {
			case "samples": project_render_samples = val break
			case "distance": project_render_distance = val break
			case "ssao": project_render_ssao = val break
			case "ssao_radius": project_render_ssao_radius = val break
			case "ssao_power": project_render_ssao_power = val break
			case "ssao_color": project_render_ssao_color = val break
			case "shadows": project_render_shadows = val break
			case "shadows_sun_buffer_size": project_render_shadows_sun_buffer_size = val break
			case "shadows_spot_buffer_size": project_render_shadows_spot_buffer_size = val break
			case "shadows_point_buffer_size": project_render_shadows_point_buffer_size = val break
			case "shadows_transparent": project_render_shadows_transparent = val break
			case "subsurface_samples": project_render_subsurface_samples = val break
			case "subsurface_highlight": project_render_subsurface_highlight = val break
			case "subsurface_highlight_strength": project_render_subsurface_highlight_strength = val break
			case "indirect": project_render_indirect = val break
			case "indirect_precision": project_render_indirect_precision = val break
			case "indirect_blur_radius": project_render_indirect_blur_radius = val break
			case "indirect_strength": project_render_indirect_strength = val break
			case "reflections": project_render_reflections = val break
			case "reflections_precision": project_render_reflections_precision = val break
			case "reflections_thickness": project_render_reflections_thickness = val break
			case "reflections_fade_amount": project_render_reflections_fade_amount = val break
			case "glow": project_render_glow = val break
			case "glow_radius": project_render_glow_radius = val break
			case "glow_intensity": project_render_glow_intensity = val break
			case "glow_falloff": project_render_glow_falloff = val break
			case "glow_falloff_radius": project_render_glow_falloff_radius = val break
			case "glow_falloff_intensity": project_render_glow_falloff_intensity = val break
			case "aa": project_render_aa = val break
			case "aa_power": project_render_aa_power = val break
			case "bend_style": project_bend_style = val break
			case "opaque_leaves": project_render_opaque_leaves = val break
			case "liquid_animation": project_render_liquid_animation = val break
			case "water_reflections": project_render_water_reflections = val break
			case "block_emissive": project_render_block_emissive = val break
			case "block_subsurface": project_render_block_subsurface = val break
			case "glint_speed": project_render_glint_speed = val break
			case "glint_strength": project_render_glint_strength = val break
			case "texture_filtering": project_render_texture_filtering = val break
			case "transparent_block_texture_filtering": project_render_transparent_block_texture_filtering = val break
			case "texture_filtering_level":
				project_render_texture_filtering_level = val
				texture_set_mipmap_level(val)
				break
			case "alpha_mode": project_render_alpha_mode = val break
			case "tonemapper": project_render_tonemapper = val break
			case "exposure": project_render_exposure = val break
			case "gamma": project_render_gamma = val break
			case "material_maps": project_render_material_maps = val break
			default: log("Unknown setting", name) break
		}
	}
}
