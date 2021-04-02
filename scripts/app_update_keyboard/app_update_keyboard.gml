/// app_update_keyboard()
/// @desc Handle keyboard shortcuts.

if (keyboard_check_pressed(vk_f7) && dev_mode)
	minecraft_assets_reload()

if (keyboard_check_pressed(vk_f9))
	open_url(file_directory)

if (keyboard_check_pressed(vk_f10))
	open_url(working_directory)

if (keyboard_check_pressed(vk_f11))
	open_url(log_file)

if (keyboard_check_pressed(vk_f12))
	debug_info = !debug_info

if (window_busy = "" && !textbox_isediting)
{
	if (keybinds_map[?e_keybind.PROJECT_NEW].pressed)
		action_toolbar_new()
	
	if (keybinds_map[?e_keybind.IMPORT_ASSET].pressed)
		action_toolbar_import_asset()
	
	if (keybinds_map[?e_keybind.PROJECT_OPEN].pressed)
		action_toolbar_open()
	
	if (keybinds_map[?e_keybind.PROJECT_SAVE].pressed)
		action_toolbar_save()
	
	if (keybinds_map[?e_keybind.PROJECT_SAVE_AS].pressed)
		action_toolbar_save_as()
	
	if (keybinds_map[?e_keybind.UNDO].pressed)
		action_toolbar_undo()
	
	if (keybinds_map[?e_keybind.REDO].pressed)
		action_toolbar_redo()
	
	if (keybinds_map[?e_keybind.PLAY].pressed)
		script_execute(timeline_playing ? action_tl_play_stop : action_tl_play)
	
	if (keybinds_map[?e_keybind.PLAY_BEGINNING].pressed)
		action_tl_play_beginning()
		
	if (!timeline_playing)
	{
		if (keybinds_map[?e_keybind.MARKER_RIGHT].active)
			action_tl_right()
		
		if (keybinds_map[?e_keybind.MARKER_LEFT].active)
			action_tl_left()
	}
	
	if (keybinds_map[?e_keybind.RENDER_MODE].pressed)
		view_toggle_render()
	
	if (keybinds_map[?e_keybind.CREATE_FOLDER].pressed)
		action_tl_folder()
		
	if (keybinds_map[?e_keybind.INSTANCE_SELECT].pressed) 
	{
		if (tl_edit)
			action_tl_deselect_all()
		else
			action_tl_select_all()
	}
	if (keybinds_map[?e_keybind.INSTANCE_DUPLICATE].pressed)
		action_tl_duplicate()
	
	if (keybinds_map[?e_keybind.INSTANCE_DELETE].pressed)
		action_tl_remove()
	
	if (keybinds_map[?e_keybind.KEYFRAMES_CREATE].pressed)
		action_tl_keyframes_create()
		
	if (keybinds_map[?e_keybind.KEYFRAMES_COPY].pressed)
		tl_keyframes_copy()
	
	if (keybinds_map[?e_keybind.KEYFRAMES_CUT].pressed)
		action_tl_keyframes_cut()
	
	if (keybinds_map[?e_keybind.KEYFRAMES_PASTE].pressed)
		action_tl_keyframes_paste(timeline_mouse_pos)
	
	if (keybinds_map[?e_keybind.KEYFRAMES_DELETE].pressed)
		action_tl_keyframes_remove()
	
	if (keybinds_map[?e_keybind.PARTICLES_SPAWN].pressed)
		action_lib_pc_spawn()
	
	if (keybinds_map[?e_keybind.PARTICLES_CLEAR].pressed)
		action_lib_pc_clear()
	
	if (keybinds_map[?e_keybind.TOOL_SELECT].pressed)
		setting_tool = e_view_tool.SELECT
	
	if (keybinds_map[?e_keybind.TOOL_MOVE].pressed)
		setting_tool = e_view_tool.MOVE
	
	if (keybinds_map[?e_keybind.TOOL_ROTATE].pressed)
		setting_tool = e_view_tool.ROTATE
	
	if (keybinds_map[?e_keybind.TOOL_SCALE].pressed)
		setting_tool = e_view_tool.SCALE
	
	if (keybinds_map[?e_keybind.TOOL_BEND].pressed)
		setting_tool = e_view_tool.BEND
	
	if (keybinds_map[?e_keybind.TOOL_TRANSFORM].pressed)
		setting_tool = e_view_tool.TRANSFORM
	
	if (keybinds_map[?e_keybind.SNAP].pressed)
		setting_snap = !setting_snap
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

// Dragger changes
if (!textbox_isediting)
{
	dragger_multiplier = keyboard_check(vk_shift) ? .1 : 1
	dragger_snap = setting_snap || keyboard_check(vk_control)
}
else
{
	dragger_multiplier = 1
	dragger_snap = false
}
