/// project_save_project()

function project_save_project()
{
	json_save_object_start("project")
		
		json_save_var("name", json_string_encode(project_name))
		json_save_var("author", json_string_encode(project_author))
		json_save_var("description", json_string_encode(project_description))
		json_save_var("video_width", project_video_width)
		json_save_var("video_height", project_video_height)
		json_save_var_bool("video_keep_aspect_ratio", project_video_keep_aspect_ratio)
		json_save_var("tempo", project_tempo)
		json_save_var("grid_rows", project_grid_rows)
		json_save_var("grid_columns", project_grid_columns)
		
		if (view_main.camera = -4 || view_main.camera = -5)
			json_save_var("view_main_camera", view_main.camera)
		else
			json_save_var("view_main_camera", save_id_get(view_main.camera))
		
		if (view_second.camera = -4 || view_second.camera = -5)
			json_save_var("view_second_camera", view_second.camera)
		else
			json_save_var("view_second_camera", save_id_get(view_second.camera))
		
		json_save_object_start("timeline")
			json_save_var_bool("repeat", timeline_repeat)
			json_save_var_bool("seamless_repeat", timeline_seamless_repeat)
			json_save_var_bool("intervals_show", timeline_intervals_show)
			json_save_var("interval_size", timeline_interval_size)
			json_save_var("interval_offset", timeline_interval_offset)
			json_save_var("marker", timeline_marker)
			json_save_var("list_width", timeline.list_width)
			json_save_var("hor_scroll", timeline.hor_scroll.value)
			json_save_var("zoom", timeline_zoom)
			json_save_var_nullable("region_start", timeline_region_start)
			json_save_var_nullable("region_end", timeline_region_end)
			json_save_var_bool("show_markers", timeline_show_markers)
			json_save_var("hide_color_tag", timeline_hide_color_tag)
		json_save_object_done()
		
		json_save_object_start("work_camera")
			json_save_var_point3D("focus", cam_work_focus)
			json_save_var("angle_xy", cam_work_angle_xy)
			json_save_var("angle_z", cam_work_angle_z)
			json_save_var("roll", cam_work_roll)
			json_save_var("zoom", cam_work_zoom)
		json_save_object_done()
		
	json_save_object_done()
}
