/// tests_run()
/// @desc Performs a sequence of tests and saves the rendered results in the project folder under runs/, along with CSV tables of benchmark timing data.
///		  Render settings are overwritten during playback by text keyframes. A renderer is skipped entirely if the keyframe is invisible.

function tests_run()
{
	var framestart, frameend, singlerenderer, debugpass, debugpassall, argssettingsqueue;
	framestart = 0
	frameend = timeline_length
	singlerenderer = ""
	debugpass = -1
	debugpassall = false
	argssettingsqueue = array()
	
	// Use region, if available
	if (!test_all_frames && timeline_region_start != null)
	{
		framestart = timeline_region_start
		frameend = timeline_region_end
	}
	
	// Overwrite defaults by program arguments
	if (test_frame_start > -1)
		framestart = test_frame_start
	if (test_frame_end > -1)
		frameend = test_frame_end
	if (test_renderer != "")
	{
		singlerenderer = test_renderer
		if (!array_contains(renderer_name_list, singlerenderer))
		{
			log("Unknown test renderer", test_renderer)
			singlerenderer = ""
		}
	}
	if (test_debug_pass = "all")
		debugpassall = true
	else if (test_debug_pass != "")
	{
		debugpass = ds_list_find_index(render_pass_list, test_debug_pass)
		if (debugpass < e_render_pass.DIFFUSE)
		{
			log("Unknown test render pass", test_debug_pass)
			debugpass = -1
		}
	}
	
	log("Test project file", project_file)
	log("Test project start", framestart)
	log("Test project end", frameend)
	if (singlerenderer != "")
		log("Test project renderer", singlerenderer)
	if (test_render_settings != "")
		log("Test project render settings", test_render_settings)
	if (test_agent != "")
		log("Test project agent", test_agent)
	
	// Run the queued resource loaders without drawing their loading popup
	while (popup_loading.load_script != null)
	{
		with (popup_loading.load_object)
			script_execute(app.popup_loading.load_script)
	}
	startup_error = false
	log("Test project resources loaded")
	
	// Load base render preset, to be modified by text keyframes or program arguments
	var mirenderfile, renderpreset;
	mirenderfile = project_folder + "/test_base.mirender"
	renderpreset = new_obj(obj_render_preset)
	render_preset_map[?"test"] = renderpreset

	with (render_default_settings)
		if (file_exists_lib(mirenderfile))
			render_preset_load(mirenderfile, false)
	
	// Argument settings are applied at the start of each frame after the current camera is resolved
	if (test_render_settings != "")
		argssettingsqueue = string_split_escaped(test_render_settings, " ")

	with (renderpreset)
		render_preset_copy_settings(render_default_settings)
	
	// Show objects under "TestEnabled" folder
	with (obj_timeline)
		if (parent != app && string_contains(parent.name, "TestEnabled"))
			hide = false
	
	render_view_current = view_main
	render_particles = view_main.particles
	render_effects = view_main.effects
	render_hidden = false
	render_background = true
	render_watermark = false

	var starttime, curdatetime, curyear, curmonth, curday, testname, testdir, agentname;
	starttime = get_timer()
	curdatetime = date_current_datetime()
	curyear = date_get_year(curdatetime)
	curmonth = date_get_month(curdatetime)
	curday = date_get_day(curdatetime)
	testname = string(curyear) + (curmonth < 10 ? "0" : "") + string(curmonth) + (curday < 10 ? "0" : "") + string(curday) + "_"
	testname += string_replace_all(date_time_string(date_current_datetime()), ":", "")
	testname += "_" + graphics_api_get()
	agentname = filename_get_valid(test_agent)
	if (agentname != "")
		testname += "_" + agentname
	testname += is_optimized()  ? "" : "_DEBUG"
	testdir = project_folder + "/runs/" + testname

	directory_create_lib(project_folder + "/runs")
	directory_create_lib(testdir)
	log("Test output folder", testdir)
	 
	var csv, csvfilename;
	csv = "Frame,Renderer,Setting,Samples,Animate_ms,Total_ms,Render_ms,Surface_ms,Export_ms,Other_ms,render_world_calls,vertex_buffer_tris,vertex_buffer_submits\n"
	csvfilename = testdir + "/benchmark_" + testname + ".csv"
	
	for (timeline_marker = framestart; timeline_marker < min(timeline_length, frameend); timeline_marker++)
	{
		// Animate
		benchmark_animate_total_time = 0
		timeline_marker_previous = timeline_marker - 1
		app_update_animate()
		csv += string(timeline_marker) + ",,,," + string_format(benchmark_animate_total_time / 1000, 0, 3) + ",,,,,,\n"
		
		// Save camera values
		if (timeline_camera)
			renderpreset.cam_value = timeline_camera.value
			
		for (renderer_current = e_renderer.QUICK; renderer_current <= e_renderer.REALISTIC; renderer_current++)
		{
			var renderername, settingsqueue;
			renderername = renderer_name_list[renderer_current]
			settingsqueue = array();
			project_render_preset[renderer_current] = "test"

			// Only test a specific renderer
			if (singlerenderer != "" && singlerenderer != renderername)
				continue
				
			// Restore settings and camera to the base state for each renderer
			with (renderpreset)
				render_preset_copy_settings(render_default_settings)
			render_apply_settings(renderpreset, e_renderer.COMMON)

			if (timeline_camera)
				timeline_camera.value = renderpreset.cam_value

			if (array_length(argssettingsqueue) > 0)
			{
				// Apply custom render settings one-by-one from program arguments
				settingsqueue = argssettingsqueue
			}
			else if (array_length(argssettingsqueue) = 0)
			{
				// Apply custom render settings one-by-one from text objects on the marker with a name matching the renderer
				var skiprenderer = false;
				with (obj_timeline) {
					if (name != renderername ||
						type != e_tl_type.TEXT)
						continue
					
					if (!value[e_value.VISIBLE])
					{
						skiprenderer = true
						continue
					}
					
					if (keyframe_current = null ||
						keyframe_current.position != app.timeline_marker ||
						keyframe_current.value[e_value.TEXT] = "")
						continue
					
					settingsqueue = string_split_escaped(keyframe_current.value[e_value.TEXT], "\n")
					break
				}

				// Skip renderer for hidden keyframes
				if (skiprenderer)
					continue
			}
			
			do
			{
				var cursetting;
				if (array_length(settingsqueue) > 0)
				{
					// Apply next settings in the queue
					cursetting = array_shift(settingsqueue)
					log("Test frame", timeline_marker, renderername, cursetting)
					with (renderpreset)
						render_preset_apply_settings(cursetting, renderer_current)
					render_apply_settings(renderpreset, e_renderer.COMMON)
				}
				else
				{
					cursetting = test_render_settings
					log("Test frame", timeline_marker, renderername)
				}

				// Create filename from frame, renderer and current settings
				var exportbasename = testdir + "/" + string(timeline_marker) + "_" + renderername;
				if (cursetting != "")
					exportbasename += "_" + filename_get_valid(cursetting)
				export_filename = exportbasename + ".png"
			
				render_lights = (renderer_current != e_renderer.QUICK)
				popup_exportimage.renderer = renderer_current
			
				benchmark_render_total_time = 0
				benchmark_surface_total_time = 0
				benchmark_export_total_time = 0

				var renderstarttime, exporttime, othertime;
				renderstarttime = get_timer()
				
				// Render all samples
				export_start("export_image")
				while (export_update()) {}

				exporttime = get_timer() - renderstarttime
				othertime = exporttime - benchmark_render_total_time - benchmark_surface_total_time - benchmark_export_total_time
			
				// Create CSV row with data
				csv += string(timeline_marker) + ","
				csv += renderername + ","
				csv += string_replace_all(cursetting, ",", " ") + ","
				if (renderer_current == e_renderer.REALISTIC)
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
			
				log("Test image", export_filename, string_format(exporttime / 1000, 0, 3) + " msec")
				if (renderer_current = e_renderer.REALISTIC) // != e_renderer.QUICK later on
				{
					if (debugpassall)
					{
						for (var pass = e_render_pass.DIFFUSE; pass < e_render_pass.amount; pass++)
							tests_export_pass(exportbasename, pass)
					}
					else if (debugpass >= e_render_pass.DIFFUSE)
						tests_export_pass(exportbasename, debugpass)
				}
			}
			until (array_length(settingsqueue) = 0)
		}
	}

	// Save run data
	var totaltime = get_timer() - starttime
	log("Tests complete", string_format(totaltime / 1000, 0, 3) + " msec")
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

/// Exports a high-quality render pass for the current frame and render settings.
function tests_export_pass(directory, pass)
{
	var previouspass = project_render_pass;
	directory_create_lib(directory)
	project_render_pass = pass
	export_filename = directory + "/" + ds_list_find_value(render_pass_list, pass) + ".png"

	var starttime = get_timer();
	export_start("export_image")
	while (export_update()) {}

	log("Test render pass", export_filename, string_format((get_timer() - starttime) / 1000, 0, 3) + " msec")

	project_render_pass = previouspass
}
