/// window_draw_load_assets()

if (!minecraft_assets_load())
{
	error("errorloadassets")
	game_end()
	return 0
}

// Background
draw_clear(c_level_middle)

if (load_assets_stage = "done")
{
	load_assets_stage = "exit"
	return 0
}
else if (load_assets_stage = "exit")
{
	window_state = "startup"
	app_startup_interface()
	
	// Deactivate instances for better performance
	instance_deactivate_object(obj_deactivate)
	
	return 0
}

content_x = 28
content_y = 28
content_width = window_width - 56
content_height = window_height - 56

draw_sprite(spr_load_assets, 0, window_width / 2, window_height - 144)

draw_label(text_get("startuploadingassets"), window_width / 2, window_height - 34, fa_middle, fa_bottom, c_text_secondary, a_text_secondary, font_body_big)

draw_box(0, window_height - 8, window_width, 8, false, c_level_bottom, 1)
draw_box(0, window_height - 8, window_width * load_assets_progress, 8, false, c_accent, 1)

current_step++