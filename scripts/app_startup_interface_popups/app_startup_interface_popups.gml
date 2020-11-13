/// app_startup_interface_popups()

// About
popup_about = new_popup("about", popup_about_draw, 542, 480, false, true)

// Startup
popup_startup = new_popup("startup", popup_startup_draw, 760, 586, true)
with (popup_startup)
	recent_scroll = new(obj_scrollbar)

// New project
popup_newproject = new_popup("newproject", popup_newproject_draw, 380, 212, true)
with (popup_newproject)
{
	folder = ""
	tbx_name = new_textbox(true, 0, "")
	tbx_author = new_textbox(true, 0, "")
	tbx_description = new_textbox(false, 0, "")
	tbx_name.next_tbx = tbx_author
	tbx_author.next_tbx = tbx_description
	tbx_description.next_tbx = tbx_name
}

// Open
popup_open = new_popup("open", popup_open_draw, 760, 520, true)
with (popup_open)
	recent_scroll = new(obj_scrollbar)

// Save as
popup_saveas = new_popup("saveas", popup_saveas_draw, 450, 380, true)
with (popup_saveas)
{
	folder = ""
	tbx_name = new_textbox(true, 0, "")
	tbx_author = new_textbox(true, 0, "")
	tbx_description = new_textbox(false, 0, "")
	tbx_name.next_tbx = tbx_author
	tbx_author.next_tbx = tbx_description
	tbx_description.next_tbx = tbx_name
}

// Color picker
popup_colorpicker = new_popup("colorpicker", popup_colorpicker_draw, 228, 440, false, true)
with (popup_colorpicker)
{
	value_name = ""
	value_script = null
	color = null
	def = null
	hue = 0
	saturation = 0
	value = 0
	tbx_red = new_textbox(1, 3, "0123456789")
	tbx_green = new_textbox(1, 3, "0123456789")
	tbx_blue = new_textbox(1, 3, "0123456789")
	tbx_hue = new_textbox(1, 3, "0123456789")
	tbx_saturation = new_textbox(1, 3, "0123456789")
	tbx_brightness = new_textbox(1, 3, "0123456789")
	tbx_hexadecimal = new_textbox_hex()
	tbx_red.next_tbx = tbx_green
	tbx_green.next_tbx = tbx_blue
	tbx_blue.next_tbx = tbx_hexadecimal
	tbx_hexadecimal.next_tbx = tbx_red
}

// Loading
popup_loading = new_popup("loading", popup_loading_draw, 400, 56, true, true)
with (popup_loading)
{
	load_object = null
	load_script = null
	progress = 0
	text = ""
}

// Download skin
popup_downloadskin = new_popup("downloadskin", popup_downloadskin_draw, 300, 312, true)
with (popup_downloadskin)
{
	value_script = null
	username = ""
	texture = null
	fail_message = ""
	start_time = 0
	tbx_username = new_textbox(true, 0, "")
}

// Import image
popup_importimage = new_popup("importimage", popup_importimage_draw, 236, 312, true)
with (popup_importimage)
{
	filename = ""
	type = e_res_type.SKIN
}

// Import item sheet
popup_importitemsheet = new_popup("importitemsheet", popup_importitemsheet_draw, 288, 488, true)
with (popup_importitemsheet)
{
	filename = ""
	value_script = null
	texture = null
	is_sheet = true
	sheet_size = vec2(item_sheet_width, item_sheet_height)
	sheet_size_def = sheet_size
	tbx_sheet_width = new_textbox_integer()
	tbx_sheet_height = new_textbox_integer()
}

// Export movie
popup_exportmovie = new_popup("exportmovie", popup_exportmovie_draw, 500, 380, true)
with (popup_exportmovie)
{
	format = app.setting_export_movie_format
	frame_rate = app.setting_export_movie_frame_rate
	bit_rate = app.setting_export_movie_bit_rate
	video_quality = find_videoquality(bit_rate)
	include_audio = app.setting_export_movie_include_audio
	remove_background = app.setting_export_movie_remove_background
	include_hidden = app.setting_export_movie_include_hidden
	high_quality = app.setting_export_movie_high_quality
	tbx_video_size_custom_width = new_textbox_integer()
	tbx_video_size_custom_height = new_textbox_integer()
	tbx_bit_rate = new_textbox_integer()
}

// Export image
popup_exportimage = new_popup("exportimage", popup_exportimage_draw, 500, 322, true)
with (popup_exportimage)
{
	remove_background = app.setting_export_image_remove_background
	include_hidden = app.setting_export_image_include_hidden
	high_quality = app.setting_export_image_high_quality
	tbx_video_size_custom_width = new_textbox_integer()
	tbx_video_size_custom_height = new_textbox_integer()
}

// Upgrade
popup_upgrade = new_popup("upgrade", popup_upgrade_draw, 360, 520, true, false, true)
with (popup_upgrade)
{
	tbx_key = new_textbox(true, 8, "")
	warntext = ""
}

// Modelbench ad
popup_modelbench = new_popup("modelbench", popup_modelbench_draw, 650, 600, true)
with (popup_modelbench)
{
	hidden = app.setting_modelbench_popup_hidden
	not_now = false
}

// Banner editor
popup_bannereditor = new_popup("bannereditor", popup_bannereditor_draw, 653, 506, true, true)
with (popup_bannereditor)
{
	preview = new(obj_preview)
	preview.fov = 30
	
	layer_scrollbar = new(obj_scrollbar)
	//layer_scrollbar.snap_value = 48
	
	layer_remove = null
	layer_edit = null
	
	banner_edit = null
	banner_edit_preview = null
	
	pattern_list_edit = ds_list_create()
	pattern_color_list_edit = ds_list_create()
	
	pattern_sprites = array()
	
	res_ratio = 1
	pattern_resource = mc_res
	
	update = false
	layer_move = null
	layer_move_x = 0
	layer_move_y = 0
}
