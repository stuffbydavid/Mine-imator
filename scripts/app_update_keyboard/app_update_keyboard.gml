/// app_update_keyboard()
/// @desc Handle keyboard shortcuts.

if (keyboard_check_pressed(vk_f8) && dev_mode)
	popup_show(popup_startup)

if (keyboard_check_pressed(vk_f9))
	open_url(file_directory)

if (keyboard_check_pressed(vk_f10))
	open_url(working_directory)

if (keyboard_check_pressed(vk_f11))
	open_url(log_file)

if (keyboard_check_pressed(vk_f12))
	debug_info=!debug_info

if (window_busy = "" && !textbox_isediting)
{
	if (keyboard_check_pressed(setting_key_new) && app_check_control(setting_key_new_control))
		action_toolbar_new()
	
	if (keyboard_check_pressed(setting_key_import_asset) && app_check_control(setting_key_import_asset_control))
		action_toolbar_import_asset()
	
	if (keyboard_check_pressed(setting_key_open) && app_check_control(setting_key_open_control))
		action_toolbar_open()
	
	if (keyboard_check_pressed(setting_key_save) && app_check_control(setting_key_save_control))
		action_toolbar_save()
	
	if (keyboard_check_pressed(setting_key_undo) && app_check_control(setting_key_undo_control))
		action_toolbar_undo()
	
	if (keyboard_check_pressed(setting_key_redo) && app_check_control(setting_key_redo_control))
		action_toolbar_redo()
	
	if (keyboard_check_pressed(setting_key_play) && app_check_control(setting_key_play_control))
		script_execute(test(timeline_playing, action_toolbar_play_stop, action_toolbar_play))
	
	if (keyboard_check_pressed(setting_key_play_beginning) && app_check_control(setting_key_play_beginning_control))
		action_toolbar_play_beginning()
		
	if (!timeline_playing)
	{
		if (keyboard_check(setting_key_move_marker_right) && app_check_control(setting_key_move_marker_right_control))
			action_tl_right()
		
		if (keyboard_check(setting_key_move_marker_left) && app_check_control(setting_key_move_marker_left_control))
			action_tl_left()
	}
	if (keyboard_check_pressed(setting_key_render) && app_check_control(setting_key_render_control))
		view_toggle_render()
	
	if (keyboard_check_pressed(setting_key_folder) && app_check_control(setting_key_folder_control))
		action_tl_folder()
		
	if (keyboard_check_pressed(setting_key_select_timelines) && app_check_control(setting_key_select_timelines_control)) 
	{
		if (tl_edit)
			action_tl_deselect_all()
		else
			action_tl_select_all()
	}
	if (keyboard_check_pressed(setting_key_duplicate_timelines) && app_check_control(setting_key_duplicate_timelines_control))
		action_tl_duplicate()
	
	if (keyboard_check_pressed(setting_key_remove_timelines) && app_check_control(setting_key_remove_timelines_control))
		action_tl_remove()
	
	if (keyboard_check_pressed(setting_key_copy_keyframes) && app_check_control(setting_key_copy_keyframes_control))
		action_tl_keyframes_copy()
	
	if (keyboard_check_pressed(setting_key_cut_keyframes) && app_check_control(setting_key_cut_keyframes_control))
		action_tl_keyframes_cut()
	
	if (keyboard_check_pressed(setting_key_paste_keyframes) && app_check_control(setting_key_paste_keyframes_control))
		action_tl_keyframes_paste(timeline_mouse_pos)
	
	if (keyboard_check_pressed(setting_key_remove_keyframes) && app_check_control(setting_key_remove_keyframes_control))
		action_tl_keyframes_remove()
	
	if (keyboard_check_pressed(setting_key_spawn_particles) && app_check_control(setting_key_spawn_particles_control))
		action_lib_pc_spawn()
	
	if (keyboard_check_pressed(setting_key_clear_particles) && app_check_control(setting_key_clear_particles_control))
		action_lib_pc_clear()
}
else if (textbox_isediting && keyboard_check_pressed(vk_tab) && textbox_lastfocus.next_tbx)
	window_focus = string(textbox_lastfocus.next_tbx)

if (textbox_isediting && !textbox_isediting_respond)
{
	textbox_isediting = false
	if (window_busy = "")
		window_focus = ""
}

textbox_isediting_respond = false
