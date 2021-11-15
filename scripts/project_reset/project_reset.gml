/// project_reset()

function project_reset()
{
	log("Resetting project")
	
	project_reset_backup()
	history_clear()
	
	temp_edit = null
	res_edit = null
	tl_edit = null
	tl_edit_amount = 0
	
	render_free()
	render_samples = -1
	
	lib_preview.update = true
	res_preview.update = true
	
	project_file = ""
	project_folder = ""
	project_changed = false
	project_name = ""
	project_author = ""
	project_description = ""
	project_video_width = 1280
	project_video_height = 720
	project_video_template = find_videotemplate(project_video_width, project_video_height)
	project_video_keep_aspect_ratio = true
	project_tempo = 24
	project_grid_rows = 3
	project_grid_columns = 3
	view_main.camera = -4
	view_second.camera = -5
	
	app_update_step = 0
	app_update_index = 0
	
	ds_list_clear(project_model_list)
	
	camera_work_reset()
	
	log("Destroying instances")
	
	with (obj_template)
		instance_destroy()
	
	with (obj_timeline)
		if (!delete_ready)
			tl_remove_clean()
	
	with (obj_timeline)
		instance_destroy()
	
	with (obj_resource)
		if (id != mc_res)
			instance_destroy()
	
	with (obj_keyframe)
		instance_destroy()
	
	with (obj_marker)
		instance_destroy()
	
	with (mc_res)
		count = 0
	
	project_reset_render()
	project_reset_background()
	
	timeline.hor_scroll.value = 0
	timeline.ver_scroll.value = 0
	
	action_tl_play_break()
	timeline_repeat = false
	timeline_marker = 0
	timeline_marker_previous = 0
	timeline_length = 0
	timeline_zoom = 16
	timeline_zoom_goal = 16
	timeline_camera = null
	copy_kf_amount = 0
	timeline_marker_length = 0
	
	timeline_intervals_show = false
	timeline_interval_size = 24
	timeline_interval_offset = 0
	timeline_hide_color_tag = array_create(9, false)
	
	ds_list_clear(tree_list)
	ds_list_clear(tree_visible_list)
	ds_list_clear(project_timeline_list)
	
	app_update_tl_edit()
	
	for (var v = 0; v < e_value.amount; v++)
		value_default[v] = tl_value_default(v)
	
	log("Project resetted")
}
