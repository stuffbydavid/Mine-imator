/// app_startup_interface_timeline()

function app_startup_interface_timeline()
{
	timeline_playing = false
	timeline_playing_start_time = 0
	timeline_playing_start_marker = 0
	timeline_playing_last_marker = 0
	timeline_playing_start_hor_scroll = 0
	
	timeline_repeat = false
	timeline_seamless_repeat = false
	timeline_intervals_show = false
	timeline_interval_size = 24
	timeline_interval_offset = 0
	timeline_list_first = 0
	timeline_list_visible = 0
	timeline_mouse_pos = null
	timeline_marker = 0
	timeline_marker_move = 0
	timeline_marker_previous = 0
	timeline_region_start = null
	timeline_region_end = null
	timeline_region_pos = 0
	timeline_length = 0
	timeline_zoom = 16
	timeline_zoom_goal = 16
	timeline_zoom_current = 16
	timeline_zoom_target = 0
	timeline_camera = null
	timeline_insert_pos = 0
	timeline_show_frames = false
	timeline_marker_length = 0
	
	timeline_move_obj = null
	timeline_move_highlight_tl = null
	timeline_move_highlight_pos = null
	timeline_move_off_x = 0
	timeline_move_off_y = 0
	timeline_move_kf = null
	timeline_move_kf_mouse_pos = null
	timeline_sound_resize_mouse_pos = null
	timeline_sound_end_mousex = 0
	timeline_sound_end_value = 0
	
	timeline_settings = false
	timeline_settings_import_loop_tl = null
	timeline_settings_walk_fn = ""
	timeline_settings_run_fn = ""
	timeline_settings_keyframes = false
	timeline_settings_keyframes_export = false
	
	copy_kf_amount = 0
	copy_kf_pos[0] = 0
	copy_kf_value[0, 0] = 0
	copy_kf_tl_save_id[0] = ""
	copy_kf_tl_part_of_save_id[0] = ""
	copy_kf_tl_model_part_name[0] = null
	
	tree_list = ds_list_create()
	tree_list_filter = ds_list_create()
	tree_visible_list = ds_list_create()
	tree_update_parent_filter = app
	tree_update_extend = false
	tree_update_color = null
	
	project_model_list = ds_list_create()
	project_timeline_list = ds_list_create()
	
	timeline_settings_w = 0
	timeline_settings_right_w = 0
	
	timeline_marker_list = ds_list_create()
	timeline_marker_current = null
	timeline_marker_edit = null
	timeline_marker_edit_offset = 0
	
	timeline_search = ""
	timeline_rename = null
	
	timeline_hide_color_tag = array_create(9, false)
	
	timeline_select_box_min = [no_limit, no_limit, no_limit]
	timeline_select_box_max = [-no_limit, -no_limit, -no_limit]
	
	// tl_update_list_indent scope fix
	with (obj_timeline)
		tl_update_list()
}
