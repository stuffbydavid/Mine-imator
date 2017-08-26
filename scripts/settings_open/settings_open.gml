/// settings_open()
/// @desc Formats:
///			settings_100demo4 = Initial
///			settings_100demo5 = added spawn objects and camera
///			settings_100 = added undo / redo shortcuts, project folder, ssao, shadows, dof, aa, grid size, even more shortcuts, panels, tabs, views, z is up, fps
///			settings_103 = compact timeline, jump to select, real time render
///			settings_106 = wave animation, exportmovie / image settings
///			settings_106_2 = block brightness
///			settings_106_3 = remove camera buffer size
///			settings_110 = texture filtering level
/*
if (!file_exists_lib(settings_file))
	return 0

log("Loading settings", settings_file)

buffer_current = buffer_import(settings_file)
load_format = buffer_read_byte()

log("load_format", load_format)

if (load_format > settings_format)
{
	buffer_delete(buffer_current)
	return 0
}

if (load_format >= settings_100)
{
	room_speed = buffer_read_byte()							debug("room_speed", room_speed)
	setting_project_folder = buffer_read_string_int()		debug("setting_project_folder", setting_project_folder)
}

setting_backup = buffer_read_byte()							debug("setting_backup", setting_backup)
setting_backup_time = buffer_read_byte()					debug("setting_backup_time", setting_backup_time)
setting_backup_amount = buffer_read_byte()					debug("setting_backup_amount", setting_backup_amount)
if (load_format < settings_100)
	buffer_read_byte() // setting_copy_projects
if (load_format >= settings_100demo5)
{
	setting_spawn_objects = buffer_read_byte()				debug("setting_spawn_objects", setting_spawn_objects)
	setting_spawn_cameras = buffer_read_byte()				debug("setting_spawn_cameras", setting_spawn_cameras)
}

setting_tip_show = buffer_read_byte()						debug("setting_tip_show", setting_tip_show)
setting_tip_delay = buffer_read_double()					debug("setting_tip_delay", setting_tip_delay)

if (load_format >= settings_100)
{
	setting_view_grid_size_hor = buffer_read_byte()			debug("setting_view_grid_size_hor", setting_view_grid_size_hor)
	setting_view_grid_size_ver = buffer_read_byte()			debug("setting_view_grid_size_ver", setting_view_grid_size_ver)
}
if (load_format >= settings_103)
{
	setting_view_real_time_render = buffer_read_byte()		debug("setting_view_real_time_render", setting_view_real_time_render)
	setting_view_real_time_render_time = buffer_read_int()  debug("setting_view_real_time_render_time", setting_view_real_time_render_time)
}
	
setting_font_filename = buffer_read_string_int()			debug("setting_font_filename", setting_font_filename)
if (!file_exists_lib(setting_font_filename))
	setting_font_filename = ""

if (setting_font_filename != "") 
{
	setting_font = font_import(setting_font_filename, 10, 0, 0)
	setting_font_bold = font_import(setting_font_filename, 10, 1, 0)
}

setting_language_filename = buffer_read_string_int()		debug("setting_language_filename", setting_language_filename)
if (!file_exists_lib(setting_language_filename))
	setting_language_filename = language_file

if (setting_language_filename != language_file)
	language_load(setting_language_filename, language_map)

if (load_format < settings_100)
{
	buffer_read_int() // setting_color
	buffer_read_int() // setting_color_text
	buffer_read_int() // setting_color_highlight
	buffer_read_int() // setting_color_highlight_text
	buffer_read_int() // setting_color_boxes
	buffer_read_int() // setting_color_boxes_text
	buffer_read_int() // setting_color_buttons
	buffer_read_int() // setting_color_buttons_text
	buffer_read_int() // setting_color_timeline
	buffer_read_int() // setting_color_timeline_text
} 
else
	settings_read_colors()

setting_timeline_autoscroll = buffer_read_byte()			debug("setting_timeline_autoscroll", setting_timeline_autoscroll)
if (load_format >= settings_103)
{
	setting_timeline_compact = buffer_read_byte()			debug("setting_timeline_compact", setting_timeline_compact)
	setting_timeline_select_jump = buffer_read_byte()		debug("setting_timeline_select_jump", setting_timeline_select_jump)
}

if (load_format >= settings_100)
	setting_z_is_up = buffer_read_byte()					debug("setting_z_is_up", setting_z_is_up)

setting_key_new = buffer_read_byte()						debug("setting_key_new", setting_key_new)
setting_key_new_control = buffer_read_byte()				debug("setting_key_new_control", setting_key_new_control)
if (load_format >= settings_100)
{
	setting_key_import_asset = buffer_read_byte()			debug("setting_key_import_asset", setting_key_import_asset)
	setting_key_import_asset_control = buffer_read_byte()	debug("setting_key_import_asset_control", setting_key_import_asset_control)
}

setting_key_open = buffer_read_byte()						debug("setting_key_open", setting_key_open)
setting_key_open_control = buffer_read_byte()				debug("setting_key_open_control", setting_key_open_control)
setting_key_save = buffer_read_byte()						debug("setting_key_save", setting_key_save)
setting_key_save_control = buffer_read_byte()				debug("setting_key_save_control", setting_key_save_control)

if (load_format >= settings_100)
{
	setting_key_undo = buffer_read_byte()							debug("setting_key_undo", setting_key_undo)
	setting_key_undo_control = buffer_read_byte()					debug("setting_key_undo_control", setting_key_undo_control)
	setting_key_redo = buffer_read_byte()							debug("setting_key_redo", setting_key_redo)
	setting_key_redo_control = buffer_read_byte()					debug("setting_key_redo_control", setting_key_redo_control)
	setting_key_play = buffer_read_byte()							debug("setting_key_play", setting_key_play)
	setting_key_play_control = buffer_read_byte()					debug("setting_key_play_control", setting_key_play_control)
	setting_key_play_beginning = buffer_read_byte()					debug("setting_key_play_beginning", setting_key_play_beginning)
	setting_key_play_beginning_control = buffer_read_byte()			debug("setting_key_play_beginning_control", setting_key_play_beginning_control)
	setting_key_move_marker_right = buffer_read_byte()				debug("setting_key_move_marker_right", setting_key_move_marker_right)
	setting_key_move_marker_right_control = buffer_read_byte()		debug("setting_key_move_marker_right_control", setting_key_move_marker_right_control)
	setting_key_move_marker_left = buffer_read_byte()				debug("setting_key_move_marker_left", setting_key_move_marker_left)
	setting_key_move_marker_left_control = buffer_read_byte()		debug("setting_key_move_marker_left_control", setting_key_move_marker_left_control)
	setting_key_render = buffer_read_byte()							debug("setting_key_render", setting_key_render)
	setting_key_render_control = buffer_read_byte()					debug("setting_key_render_control", setting_key_render_control)
	setting_key_folder = buffer_read_byte()							debug("setting_key_folder", setting_key_folder)
	setting_key_folder_control = buffer_read_byte()					debug("setting_key_folder_control", setting_key_folder_control)
	setting_key_select_timelines = buffer_read_byte()				debug("setting_key_select_timelines", setting_key_select_timelines)
	setting_key_select_timelines_control = buffer_read_byte()		debug("setting_key_select_timelines_control", setting_key_select_timelines_control)
	setting_key_duplicate_timelines = buffer_read_byte()			debug("setting_key_duplicate_timelines", setting_key_duplicate_timelines)
	setting_key_duplicate_timelines_control = buffer_read_byte()	debug("setting_key_duplicate_timelines_control", setting_key_duplicate_timelines_control)
	setting_key_remove_timelines = buffer_read_byte()				debug("setting_key_remove_timelines", setting_key_remove_timelines)
	setting_key_remove_timelines_control = buffer_read_byte()		debug("setting_key_remove_timelines_control", setting_key_remove_timelines_control)
}

setting_key_copy_keyframes = buffer_read_byte()						debug("setting_key_copy_keyframes", setting_key_copy_keyframes)
setting_key_copy_keyframes_control = buffer_read_byte()				debug("setting_key_copy_keyframes_control", setting_key_copy_keyframes_control)
setting_key_cut_keyframes = buffer_read_byte()						debug("setting_key_cut_keyframes", setting_key_cut_keyframes)
setting_key_cut_keyframes_control = buffer_read_byte()				debug("setting_key_cut_keyframes_control", setting_key_cut_keyframes_control)
setting_key_paste_keyframes = buffer_read_byte()					debug("setting_key_paste_keyframes", setting_key_paste_keyframes)
setting_key_paste_keyframes_control = buffer_read_byte()			debug("setting_key_paste_keyframes_control", setting_key_paste_keyframes_control)
setting_key_remove_keyframes = buffer_read_byte()					debug("setting_key_remove_keyframes", setting_key_folder)
setting_key_remove_keyframes_control = buffer_read_byte()			debug("setting_key_remove_keyframes_control", setting_key_remove_keyframes_control)
setting_key_spawn_particles = buffer_read_byte()					debug("setting_key_spawn_particles", setting_key_spawn_particles)
setting_key_spawn_particles_control = buffer_read_byte()			debug("setting_key_spawn_particles_control", setting_key_spawn_particles_control)
setting_key_clear_particles = buffer_read_byte()					debug("setting_key_clear_particles", setting_key_clear_particles)
setting_key_clear_particles_control = buffer_read_byte()			debug("setting_key_clear_particles_control", setting_key_clear_particles_control)

if (load_format < settings_100)
{
	setting_key_play = buffer_read_byte()						debug("setting_key_play", setting_key_play)
	setting_key_play_control = buffer_read_byte()				debug("setting_key_play_control", setting_key_play_control)
	setting_key_play_beginning = buffer_read_byte()				debug("setting_key_play_beginning", setting_key_play_beginning)
	setting_key_play_beginning_control = buffer_read_byte()		debug("setting_key_play_beginning_control", setting_key_play_beginning_control)
}

setting_key_forward = buffer_read_byte()			debug("setting_key_forward", setting_key_forward)
setting_key_back = buffer_read_byte()				debug("setting_key_back", setting_key_back)
setting_key_left = buffer_read_byte()				debug("setting_key_left", setting_key_left)
setting_key_right = buffer_read_byte()				debug("setting_key_right", setting_key_right)
setting_key_ascend = buffer_read_byte()				debug("setting_key_ascend", setting_key_ascend)
setting_key_descend = buffer_read_byte()			debug("setting_key_descend", setting_key_descend)
setting_key_roll_forward = buffer_read_byte()		debug("setting_key_roll_forward", setting_key_roll_forward)
setting_key_roll_back = buffer_read_byte()			debug("setting_key_roll_back", setting_key_roll_back)
setting_key_roll_reset = buffer_read_byte()			debug("setting_key_roll_reset", setting_key_roll_reset)
setting_key_reset = buffer_read_byte()				debug("setting_key_reset", setting_key_reset)
setting_key_fast = buffer_read_byte()				debug("setting_key_fast", setting_key_fast)
setting_key_slow = buffer_read_byte()				debug("setting_key_slow", setting_key_slow)
setting_move_speed = buffer_read_double()			debug("setting_move_speed", setting_move_speed)
setting_look_sensitivity = buffer_read_double()		debug("setting_look_sensitivity", setting_look_sensitivity)
setting_fast_modifier = buffer_read_double()		debug("setting_fast_modifier", setting_fast_modifier)
setting_slow_modifier = buffer_read_double()		debug("setting_slow_modifier", setting_slow_modifier)

setting_bend_round_default = buffer_read_byte()					debug("setting_bend_round_default", setting_bend_round_default)
setting_bend_detail = buffer_read_int()							debug("setting_bend_detail", setting_bend_detail)
setting_bend_scale = buffer_read_double()						debug("setting_bend_scale", setting_bend_scale)
setting_schematic_remove_edges = buffer_read_byte()				debug("setting_schematic_remove_edges", setting_schematic_remove_edges)

if (load_format >= settings_106)
	setting_liquid_animation = buffer_read_byte()				debug("setting_liquid_animation", setting_liquid_animation)

if (load_format >= settings_100)
{
	setting_texture_filtering = buffer_read_byte()				debug("setting_texture_filtering", setting_texture_filtering)
	setting_transparent_texture_filtering = buffer_read_byte()	debug("setting_transparent_texture_filtering", setting_transparent_texture_filtering)
	if (load_format >= settings_110)
		setting_texture_filtering_level = buffer_read_byte()	debug("setting_texture_filtering_level", setting_texture_filtering_level)
	if (load_format >= settings_106_2)
		setting_block_brightness = buffer_read_double()			debug("setting_block_brightness", setting_block_brightness)
	if (load_format < settings_106_3)
		buffer_read_int() // setting_camera_buffer_size
	
	setting_render_ssao = buffer_read_byte()					debug("setting_render_ssao", setting_render_ssao)
	setting_render_ssao_radius = buffer_read_double()			debug("setting_render_ssao_radius", setting_render_ssao_radius)
	setting_render_ssao_power = buffer_read_double()			debug("setting_render_ssao_power", setting_render_ssao_power)
	setting_render_ssao_blur_passes = buffer_read_byte()		debug("setting_render_ssao_blur_passes", setting_render_ssao_blur_passes)
	setting_render_ssao_color = buffer_read_int()				debug("setting_render_ssao_color", setting_render_ssao_color)
	
	setting_render_shadows = buffer_read_byte()					debug("setting_render_shadows", setting_render_shadows)
}

setting_render_shadows_sun_buffer_size = buffer_read_int()		debug("setting_render_shadows_sun_buffer_size", setting_render_shadows_sun_buffer_size)
setting_render_shadows_spot_buffer_size = buffer_read_int()		debug("setting_render_shadows_spot_buffer_size", setting_render_shadows_spot_buffer_size)
setting_render_shadows_point_buffer_size = buffer_read_int()	debug("setting_render_shadows_point_buffer_size", setting_render_shadows_point_buffer_size)

if (load_format >= settings_100)
{
	setting_render_shadows_blur_quality = buffer_read_byte()	debug("setting_render_shadows_blur_quality", setting_render_shadows_blur_quality)
	setting_render_shadows_blur_size = buffer_read_double()		debug("setting_render_shadows_blur_size", setting_render_shadows_blur_size)
	
	setting_render_dof = buffer_read_byte()						debug("setting_render_dof", setting_render_dof)
	setting_render_dof_blur_size = buffer_read_double()			debug("setting_render_dof_blur_size", setting_render_dof_blur_size)
	
	setting_render_aa = buffer_read_byte()						debug("setting_render_aa", setting_render_aa)
	setting_render_aa_power = buffer_read_double()				debug("setting_render_aa_power", setting_render_aa_power)
	
	setting_render_watermark = buffer_read_byte()				debug("setting_render_watermark", setting_render_watermark)
	if (trial_version)
		setting_render_watermark = true
	
	toolbar_location = buffer_read_string_int()					debug("toolbar_location", toolbar_location)
	toolbar_size = buffer_read_double()							debug("toolbar_size", toolbar_size)
	
	panel_left_bottom.size = buffer_read_double()				debug("panel_left_bottom.size", panel_left_bottom.size)
	panel_right_bottom.size = buffer_read_double()				debug("panel_right_bottom.size", panel_right_bottom.size)
	panel_bottom.size = buffer_read_double()					debug("panel_bottom.size", panel_bottom.size)
	panel_top.size = buffer_read_double()						debug("panel_top.size", panel_top.size)
	panel_left_top.size = buffer_read_double()					debug("panel_left_top.size", panel_left_top.size)
	panel_right_top.size = buffer_read_double()					debug("panel_right_top.size", panel_right_top.size)
	
	panel_tab_list_remove(panel_right_top, properties)
	panel_tab_list_add(settings_open_panel(), 0, properties)	debug("properties.panel.num", properties.panel.num)
	
	ground_editor.panel = settings_open_panel()					debug("ground_editor.panel.num", ground_editor.panel.num)
	template_editor.panel = settings_open_panel()				debug("template_editor.panel.num", template_editor.panel.num)
	
	panel_tab_list_remove(panel_bottom, timeline)
	panel_tab_list_add(settings_open_panel(), 0, timeline)		debug("timeline.panel.num", timeline.panel.num)
	
	timeline_editor.panel = settings_open_panel()				debug("timeline_editor.panel.num", timeline_editor.panel.num)
	frame_editor.panel = settings_open_panel()					debug("frame_editor.panel.num", frame_editor.panel.num)
	settings.panel = settings_open_panel()						debug("settings.panel.num", settings.panel.num)
	
	view_split = buffer_read_double()							debug("view_split", view_split)
	
	view_main.controls = buffer_read_byte()						debug("view_main.controls", view_main.controls)
	view_main.lights = buffer_read_byte()						debug("view_main.lights", view_main.lights)
	view_main.particles = buffer_read_byte()					debug("view_main.particles", view_main.particles)
	view_main.grid = buffer_read_byte()							debug("view_main.grid", view_main.grid)
	view_main.aspect_ratio = buffer_read_byte()					debug("view_main.aspect_ratio", view_main.aspect_ratio)
	view_main.location = buffer_read_string_int()				debug("view_main.location", view_main.location)
	
	view_second.show = buffer_read_byte()						debug("view_second.show", view_second.show)
	view_second.controls = buffer_read_byte()					debug("view_second.controls", view_second.controls)
	view_second.lights = buffer_read_byte()						debug("view_second.lights", view_second.lights)
	view_second.particles = buffer_read_byte()					debug("view_second.particles", view_second.particles)
	view_second.grid = buffer_read_byte()						debug("view_second.grid", view_second.grid)
	view_second.aspect_ratio = buffer_read_byte()				debug("view_second.aspect_ratio", view_second.aspect_ratio)
	view_second.location = buffer_read_string_int()				debug("view_second.location", view_second.location)
	view_second.width = buffer_read_double()					debug("view_second.width", view_second.width)
	view_second.height = buffer_read_double()					debug("view_second.height", view_second.height)
	
	frame_editor.color.advanced = buffer_read_byte()			debug("frame_editor.color.advanced", frame_editor.color.advanced)
}
else
{
	buffer_read_int() // setting_camera_buffer_size
	setting_render_shadows_blur_quality = buffer_read_byte()			debug("setting_render_shadows_blur_quality", setting_render_shadows_blur_quality)
	setting_render_shadows_blur_size = min(buffer_read_double(), 4)		debug("setting_render_shadows_blur_size", setting_render_shadows_blur_size)
	setting_render_dof_blur_size = buffer_read_double()					debug("setting_render_dof_blur_size", setting_render_dof_blur_size)
}

if (load_format >= settings_106)
{
	popup_exportmovie.format = buffer_read_string_int()			debug("popup_exportmovie.format", popup_exportmovie.format)
	popup_exportmovie.frame_rate = buffer_read_byte()			debug("popup_exportmovie.frame_rate", popup_exportmovie.frame_rate)
	popup_exportmovie.bit_rate = buffer_read_int()				debug("popup_exportmovie.bit_rate", popup_exportmovie.bit_rate)
	popup_exportmovie.video_quality = find_videoquality(popup_exportmovie.bit_rate)
	popup_exportmovie.include_audio = buffer_read_byte()		debug("popup_exportmovie.include_audio", popup_exportmovie.include_audio)
	popup_exportmovie.remove_background = buffer_read_byte()	debug("popup_exportmovie.remove_background", popup_exportmovie.remove_background)
	popup_exportmovie.include_hidden = buffer_read_byte()		debug("popup_exportmovie.include_hidden", popup_exportmovie.include_hidden)
	popup_exportmovie.high_quality = buffer_read_byte()			debug("popup_exportmovie.high_quality", popup_exportmovie.high_quality)
	popup_exportimage.remove_background = buffer_read_byte()	debug("popup_exportimage.remove_background", popup_exportimage.remove_background)
	popup_exportimage.include_hidden = buffer_read_byte()		debug("popup_exportimage.include_hidden", popup_exportimage.include_hidden)
	popup_exportimage.high_quality = buffer_read_byte()			debug("popup_exportimage.high_quality", popup_exportimage.high_quality)
}

buffer_delete(buffer_current)
*/