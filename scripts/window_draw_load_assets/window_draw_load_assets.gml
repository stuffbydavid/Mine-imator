/// window_draw_load_assets()

if (!minecraft_assets_load())
{
	error("loadassets")
	game_end()
	return 0
}

if (load_assets_stage = "done")
{
	window_busy = ""
	app_startup_interface()
	return 0
}

// Background
draw_clear(setting_color_interface)

content_x = 25
content_y = 25
content_width = window_width - 50
content_height = window_height - 50

// To keep the user somewhat entertained
draw_image(spr_load_assets, 0, content_x + content_width / 2, content_y)

// Loading
draw_loading_bar(content_x, content_y + content_height - 40, content_width, 40, load_assets_progress, text_get("loadassets" + load_assets_stage, app.setting_minecraft_version))

current_step++