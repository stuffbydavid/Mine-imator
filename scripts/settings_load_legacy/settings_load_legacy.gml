/// settings_load_legacy(filename)
/// @arg filename

var fn = argument0;

log("Loading legacy settings", fn)

buffer_current = buffer_load_lib(fn)
load_format = buffer_read_byte()
log("load_format", load_format)

if (load_format >= e_settings.FORMAT_110_PRE_1)
{
	buffer_delete(buffer_current)
	return 0
}

if (load_format >= e_settings.FORMAT_100)
{
	room_speed = buffer_read_byte()
	if (dev_mode)
		buffer_read_string_int()
	else
		setting_project_folder = buffer_read_string_int()
}

setting_backup = buffer_read_byte()
setting_backup_time = buffer_read_byte()
setting_backup_amount = buffer_read_byte()
if (load_format < e_settings.FORMAT_100)
	/*setting_copy_projects=*/buffer_read_byte()
	
if (load_format >= e_settings.FORMAT_100_DEMO_5)
{
	setting_spawn_objects = buffer_read_byte()
	setting_spawn_cameras = buffer_read_byte()
}

setting_tip_show = buffer_read_byte()
setting_tip_delay = buffer_read_double()

if (load_format >= e_settings.FORMAT_100)
{
	setting_view_grid_size_hor = buffer_read_byte()
	setting_view_grid_size_ver = buffer_read_byte()
}
if (load_format >= e_settings.FORMAT_103)
{
	setting_view_real_time_render = buffer_read_byte()
	setting_view_real_time_render_time = buffer_read_int()
}
	
setting_font_filename = buffer_read_string_int()
if (!file_exists_lib(setting_font_filename))
	setting_font_filename = ""

if (setting_font_filename != "") 
{
	setting_font = font_add_lib(setting_font_filename, 10, 0, 0)
	setting_font_bold = font_add_lib(setting_font_filename, 10, 1, 0)
}

/*setting_language_filename = */buffer_read_string_int()

if (load_format < e_settings.FORMAT_100)
{
	/*setting_color=*/buffer_read_int()
	/*setting_color_text=*/buffer_read_int()
	/*setting_color_highlight=*/buffer_read_int()
	/*setting_color_highlight_text=*/buffer_read_int()
	/*setting_color_boxes=*/buffer_read_int()
	/*setting_color_boxes_text=*/buffer_read_int()
	/*setting_color_buttons=*/buffer_read_int()
	/*setting_color_buttons_text=*/buffer_read_int()
	/*setting_color_timeline=*/buffer_read_int()
	/*setting_color_timeline_text=*/buffer_read_int()
} 
else
	settings_load_legacy_colors()

setting_timeline_autoscroll = buffer_read_byte()
if (load_format >= e_settings.FORMAT_103)
{
	setting_timeline_compact = buffer_read_byte()
	setting_timeline_select_jump = buffer_read_byte()
}

if (load_format >= e_settings.FORMAT_100)
	setting_z_is_up = buffer_read_byte()

setting_key_new = buffer_read_byte()
setting_key_new_control = buffer_read_byte()
if (load_format >= e_settings.FORMAT_100)
{
	setting_key_import_asset = buffer_read_byte()
	setting_key_import_asset_control = buffer_read_byte()
}

setting_key_open = buffer_read_byte()
setting_key_open_control = buffer_read_byte()
setting_key_save = buffer_read_byte()
setting_key_save_control = buffer_read_byte()

if (load_format >= e_settings.FORMAT_100)
{
	setting_key_undo = buffer_read_byte()
	setting_key_undo_control = buffer_read_byte()
	setting_key_redo = buffer_read_byte()
	setting_key_redo_control = buffer_read_byte()
	setting_key_play = buffer_read_byte()
	setting_key_play_control = buffer_read_byte()
	setting_key_play_beginning = buffer_read_byte()
	setting_key_play_beginning_control = buffer_read_byte()
	setting_key_move_marker_right = buffer_read_byte()
	setting_key_move_marker_right_control = buffer_read_byte()
	setting_key_move_marker_left = buffer_read_byte()
	setting_key_move_marker_left_control = buffer_read_byte()
	setting_key_render = buffer_read_byte()
	setting_key_render_control = buffer_read_byte()
	setting_key_folder = buffer_read_byte()
	setting_key_folder_control = buffer_read_byte()
	setting_key_select_timelines = buffer_read_byte()
	setting_key_select_timelines_control = buffer_read_byte()
	setting_key_duplicate_timelines = buffer_read_byte()
	setting_key_duplicate_timelines_control = buffer_read_byte()
	setting_key_remove_timelines = buffer_read_byte()
	setting_key_remove_timelines_control = buffer_read_byte()
}

setting_key_copy_keyframes = buffer_read_byte()
setting_key_copy_keyframes_control = buffer_read_byte()
setting_key_cut_keyframes = buffer_read_byte()
setting_key_cut_keyframes_control = buffer_read_byte()
setting_key_paste_keyframes = buffer_read_byte()
setting_key_paste_keyframes_control = buffer_read_byte()
setting_key_remove_keyframes = buffer_read_byte()
setting_key_remove_keyframes_control = buffer_read_byte()
setting_key_spawn_particles = buffer_read_byte()
setting_key_spawn_particles_control = buffer_read_byte()
setting_key_clear_particles = buffer_read_byte()
setting_key_clear_particles_control = buffer_read_byte()

if (load_format < e_settings.FORMAT_100)
{
	setting_key_play = buffer_read_byte()
	setting_key_play_control = buffer_read_byte()
	setting_key_play_beginning = buffer_read_byte()
	setting_key_play_beginning_control = buffer_read_byte()
}

setting_key_forward = buffer_read_byte()
setting_key_back = buffer_read_byte()
setting_key_left = buffer_read_byte()
setting_key_right = buffer_read_byte()
setting_key_ascend = buffer_read_byte()
setting_key_descend = buffer_read_byte()
setting_key_roll_forward = buffer_read_byte()
setting_key_roll_back = buffer_read_byte()
setting_key_roll_reset = buffer_read_byte()
setting_key_reset = buffer_read_byte()
setting_key_fast = buffer_read_byte()
setting_key_slow = buffer_read_byte()
setting_move_speed = buffer_read_double()
setting_look_sensitivity = buffer_read_double()
setting_fast_modifier = buffer_read_double()
setting_slow_modifier = buffer_read_double()

setting_bend_round_default = buffer_read_byte()
setting_bend_detail = buffer_read_int()
setting_bend_scale = buffer_read_double()
setting_schematic_remove_edges = buffer_read_byte()

if (load_format >= e_settings.FORMAT_106)
	setting_liquid_animation = buffer_read_byte()

if (load_format >= e_settings.FORMAT_100)
{
	setting_texture_filtering = buffer_read_byte()
	setting_transparent_texture_filtering = buffer_read_byte()
	if (load_format >= e_settings.FORMAT_106_2)
		setting_block_brightness = buffer_read_double()
	if (load_format < e_settings.FORMAT_106_3)
		/*setting_camera_buffer_size=*/buffer_read_int()
	
	setting_render_ssao = buffer_read_byte()
	setting_render_ssao_radius = buffer_read_double()
	setting_render_ssao_power = buffer_read_double()
	setting_render_ssao_blur_passes = buffer_read_byte()
	setting_render_ssao_color = buffer_read_int()
	
	setting_render_shadows = buffer_read_byte()
}

setting_render_shadows_sun_buffer_size = buffer_read_int()
setting_render_shadows_spot_buffer_size = buffer_read_int()
setting_render_shadows_point_buffer_size = buffer_read_int()

if (load_format >= e_settings.FORMAT_100)
{
	setting_render_shadows_blur_quality = buffer_read_byte()
	setting_render_shadows_blur_size = buffer_read_double()
	
	setting_render_dof = buffer_read_byte()
	setting_render_dof_blur_size = buffer_read_double()
	
	setting_render_aa = buffer_read_byte()
	setting_render_aa_power = buffer_read_double()
	
	setting_render_watermark = buffer_read_byte()
	if (trial_version)
		setting_render_watermark = true
	
	toolbar_location = buffer_read_string_int()
	toolbar_size = buffer_read_double()
	
	panel_left_bottom.size = buffer_read_double()
	panel_right_bottom.size = buffer_read_double()
	panel_bottom.size = buffer_read_double()
	panel_top.size = buffer_read_double()
	panel_left_top.size = buffer_read_double()
	panel_right_top.size = buffer_read_double()
	
	var propertiespanel = buffer_read_byte();
	var groundeditorpanel = buffer_read_byte();
	var templateeditorpanel = buffer_read_byte();
	var timelinepanel = buffer_read_byte();
	var timelineeditorpanel = buffer_read_byte();
	var frameeditorpanel = buffer_read_byte();
	var settingspanel = buffer_read_byte();
	
	panel_tab_list_remove(panel_right_top, properties)
	panel_tab_list_add(panel_list[|propertiespanel], 0, properties)
	
	ground_editor.panel = panel_list[|groundeditorpanel]
	template_editor.panel = panel_list[|templateeditorpanel]
	
	panel_tab_list_remove(panel_bottom, timeline)
	panel_tab_list_add(panel_list[|timelinepanel], 0, timeline)
	
	timeline_editor.panel = panel_list[|timelineeditorpanel]
	frame_editor.panel = panel_list[|frameeditorpanel]
	settings.panel = panel_list[|settingspanel]
	
	view_split = buffer_read_double()
	
	view_main.controls = buffer_read_byte()
	view_main.lights = buffer_read_byte()
	view_main.particles = buffer_read_byte()
	view_main.grid = buffer_read_byte()
	view_main.aspect_ratio = buffer_read_byte()
	view_main.location = buffer_read_string_int()
	
	view_second.show = buffer_read_byte()
	view_second.controls = buffer_read_byte()
	view_second.lights = buffer_read_byte()
	view_second.particles = buffer_read_byte()
	view_second.grid = buffer_read_byte()
	view_second.aspect_ratio = buffer_read_byte()
	view_second.location = buffer_read_string_int()
	view_second.width = buffer_read_double()
	view_second.height = buffer_read_double()
	
	frame_editor.color.advanced = buffer_read_byte()
}
else
{
	/*setting_camera_buffer_size=*/ buffer_read_int()
	setting_render_shadows_blur_quality = buffer_read_byte()
	setting_render_shadows_blur_size = min(buffer_read_double(), 4)
	setting_render_dof_blur_size = buffer_read_double()
}

if (load_format >= e_settings.FORMAT_106)
{
	popup_exportmovie.format = buffer_read_string_int()
	popup_exportmovie.frame_rate = buffer_read_byte()
	popup_exportmovie.bit_rate = buffer_read_int()
	popup_exportmovie.video_quality = find_videoquality(popup_exportmovie.bit_rate)
	popup_exportmovie.include_audio = buffer_read_byte()
	popup_exportmovie.remove_background = buffer_read_byte()
	popup_exportmovie.include_hidden = buffer_read_byte()
	popup_exportmovie.high_quality = buffer_read_byte()
	popup_exportimage.remove_background = buffer_read_byte()
	popup_exportimage.include_hidden = buffer_read_byte()
	popup_exportimage.high_quality = buffer_read_byte()
}
if (load_format >= e_settings.FORMAT_CB_102)
{
	/*setting_custom_interface = */buffer_read_byte()
	/*setting_render_bloom = */buffer_read_byte()
}

buffer_delete(buffer_current)