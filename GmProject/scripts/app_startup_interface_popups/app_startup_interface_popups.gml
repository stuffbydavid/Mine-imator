/// app_startup_interface_popups()

function app_startup_interface_popups()
{
	// Welcome
	popup_welcome = new_popup("welcome", popup_welcome_draw, 420, 159, true, false, false, false)
	
	// About
	popup_about = new_popup("about", popup_about_draw, 542, 480, true, true, false, true)
	
	// New project
	popup_newproject = new_popup("newproject", popup_newproject_draw, 380, null, true)
	with (popup_newproject)
	{
		folder = ""
		tbx_name = new_textbox(true, 0, "")
		tbx_author = new_textbox(true, 0, "")
		tbx_description = new_textbox(false, 0, "")
	}
	
	// Save as
	popup_saveas = new_popup("saveas", popup_saveas_draw, 380, null, true)
	with (popup_saveas)
	{
		folder = ""
		tbx_name = new_textbox(true, 0, "")
		tbx_author = new_textbox(true, 0, "")
		tbx_description = new_textbox(false, 0, "")
	}
	
	// Loading
	popup_loading = new_popup("loading", popup_loading_draw, 400, null, true, true)
	with (popup_loading)
	{
		load_object = null
		load_script = null
		progress = 0
		text = ""
	}
	
	// Download skin
	popup_downloadskin = new_popup("downloadskin", popup_downloadskin_draw, 300, null, true)
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
	popup_importimage = new_popup("importimage", popup_importimage_draw, 236, null, true)
	with (popup_importimage)
	{
		filename = ""
		type = e_res_type.SKIN
	}
	
	// Import item sheet
	popup_importitemsheet = new_popup("importitemsheet", popup_importitemsheet_draw, 288, null, true)
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
	popup_exportmovie = new_popup("exportmovie", popup_exportmovie_draw, 350, null, true)
	with (popup_exportmovie)
	{
		format = app.setting_export_movie_format
		frame_rate = app.setting_export_movie_frame_rate
		framespersecond = app.setting_export_movie_framespersecond
		bit_rate = app.setting_export_movie_bit_rate
		video_quality = find_videoquality(bit_rate)
		include_audio = app.setting_export_movie_include_audio
		remove_background = app.setting_export_movie_remove_background
		include_hidden = app.setting_export_movie_include_hidden
		high_quality = app.setting_export_movie_high_quality
		watermark = app.setting_export_movie_watermark
		tbx_video_size_custom_width = new_textbox_integer()
		tbx_video_size_custom_height = new_textbox_integer()
		tbx_framespersecond = new_textbox_integer()
		tbx_bit_rate = new_textbox_integer()
	}
	
	// Export image
	popup_exportimage = new_popup("exportimage", popup_exportimage_draw, 350, null, true)
	with (popup_exportimage)
	{
		remove_background = app.setting_export_image_remove_background
		include_hidden = app.setting_export_image_include_hidden
		high_quality = app.setting_export_image_high_quality
		watermark = app.setting_export_image_watermark
		tbx_image_size_custom_width = new_textbox_integer()
		tbx_image_size_custom_height = new_textbox_integer()
	}
	
	// Upgrade
	popup_upgrade = new_popup("upgrade", popup_upgrade_draw, 420, null, true, false, true)
	with (popup_upgrade)
	{
		tbx_key = new_textbox(true, 8, "")
		warntext = ""
		page = 0
		page_ani = 1
		page_ani_type = "right"
		
		open_advanced = false
		custom_rendering = "default"
	}
	
	// "Advanced mode" popup
	popup_advanced = new_popup("advanced", popup_advanced_draw, 420, null, true)
	
	// Modelbench ad
	popup_modelbench = new_popup("modelbench", popup_modelbench_draw, 420, null, true)
	with (popup_modelbench)
	{
		hidden = app.setting_modelbench_popup_hidden
		not_now = false
	}
	
	// Pattern editor
	popup_pattern_editor = new_popup("patterneditor", popup_pattern_editor_draw, 550, null, true, false, false, false)
	with (popup_pattern_editor)
	{
		preview = new_obj(obj_preview)
		preview.fov = 25
		preview.xy_lock = true
		
		layer_scrollbar = new_obj(obj_scrollbar)
		
		layer_remove = null
		layer_edit = null
		
		pattern_edit = null
		pattern_edit_preview = null
		
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
}
