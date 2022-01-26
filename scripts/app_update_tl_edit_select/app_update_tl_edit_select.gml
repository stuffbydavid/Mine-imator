/// app_update_tl_edit_select()

function app_update_tl_edit_select()
{
	with (frame_editor)
	{
		transform.show = false
		transform.enabled = false
		material.enabled = false
		particles.enabled = false
		light.enabled = false
		light.has_spotlight = false
		camera.show = false
		camera.enabled = false
		camera.video_template = null
		sound.enabled = false
		text.enabled = false
		item.enabled = false
		keyframe.enabled = false
	}
	
	with (timeline_editor)
	{
		graphics.enabled = false
		audio.enabled = false
	}
	
	select_kf_amount = 0
	select_kf_single = null
	
	timeline_settings = false
	timeline_settings_import_loop_tl = null
	timeline_settings_walk_fn = ""
	timeline_settings_run_fn = ""
	timeline_settings_keyframes = false
	timeline_settings_keyframes_export = false
	
	// Enable move tool
	if (!setting_tool_scale)
		setting_tool_move = true
	
	var checkwalk, checkexport, checkexportobj;
	checkwalk = true
	checkexport = true
	checkexportobj = null
	
	with (obj_timeline)
	{
		if (!selected)
			continue
		
		// Show duplicate & remove settings?
		if (part_of = null)
			app.timeline_settings = true
		
		if (keyframe_select != null)
		{
			// Show walk setting?
			if (checkwalk)
			{
				checkwalk = false
				app.timeline_settings_import_loop_tl = null
				if (type = e_tl_type.CHARACTER)
				{
					if (keyframe_select_amount = 1 && keyframe_select != null && ds_list_find_index(keyframe_list, keyframe_select) < ds_list_size(keyframe_list) - 1)
					{
						checkwalk = true
						app.timeline_settings_import_loop_tl = id
					}
				}
			}
			
			// Show keyframe settings?
			app.timeline_settings_keyframes = true
			
			// Show export button?
			if (checkexport)
			{
				var obj = ((part_of != null) ? part_of : id);
				if (checkexportobj = null)
				{
					checkexportobj = obj
					app.timeline_settings_keyframes_export = true
				}
				else if (checkexportobj != obj)
				{
					checkexport = false
					app.timeline_settings_keyframes_export = false
				}
			}
		}
		
		// Change tools
		if (!show_tool_position)
			app.setting_tool_move = tl_edit.show_tool_position
		
		// Set enabled
		if (value_type[e_value_type.TRANSFORM])
			app.frame_editor.transform.enabled = true
		
		if (value_type[e_value_type.MATERIAL])
			app.frame_editor.material.enabled = true
		
		if (value_type[e_value_type.PARTICLES])
			app.frame_editor.particles.enabled = true
		
		if (value_type[e_value_type.LIGHT])
			app.frame_editor.light.enabled = true
		
		if (value_type[e_value_type.SPOTLIGHT])
			app.frame_editor.light.has_spotlight = true
		
		if (value_type[e_value_type.CAMERA])
			app.frame_editor.camera.enabled = true
		
		if (value_type[e_value_type.SOUND])
			app.frame_editor.sound.enabled = true
		
		if (value_type[e_value_type.TEXT])
			app.frame_editor.text.enabled = true
		
		if (value_type[e_value_type.ITEM])
			app.frame_editor.item.enabled = true
		
		if (value_type[e_value_type.KEYFRAME])
			app.frame_editor.keyframe.enabled = true
		
		if (value_type[e_value_type.GRAPHICS])
			app.timeline_editor.graphics.enabled = true
		
		if (value_type[e_value_type.AUDIO])
			app.timeline_editor.audio.enabled = true
		
		// Set shown
		app.frame_editor.transform.show = true
		
		if (value_type_show[e_value_type.CAMERA])
			app.frame_editor.camera.show = true
	}
	
	if (timeline_settings_import_loop_tl != null)
	{
		// Use walk/run cycles based on model file name, if they don't exist, use cycles based on model
		var name = timeline_settings_import_loop_tl.temp.model_file.name;
		timeline_settings_walk_fn = load_assets_startup_dir + mc_loops_directory + name + "_walk.miframes"
		timeline_settings_run_fn = load_assets_startup_dir + mc_loops_directory + name + "_run.miframes"
		
		if (!file_exists(timeline_settings_walk_fn))
		{
			name = timeline_settings_import_loop_tl.temp.model_name
			timeline_settings_walk_fn = load_assets_startup_dir + mc_loops_directory + name + "_walk.miframes"
		}
		
		if (!file_exists(timeline_settings_run_fn))
		{
			name = timeline_settings_import_loop_tl.temp.model_name
			timeline_settings_run_fn = load_assets_startup_dir + mc_loops_directory + name + "_run.miframes"
		}
	}
}
