/// window_draw_load_assets()

function window_draw_load_assets()
{
	if (!minecraft_assets_load())
	{
		error("errorloadassets")
		game_end()
		return 0
	}
	
	// Background
	draw_clear(c_level_top)
	
	if (load_assets_stage = "done")
	{
		load_assets_stage = "exit"
		return 0
	}
	else if (load_assets_stage = "exit")
	{
		window_taskbar_progress_state_set()
		window_flash()
		
		window_state = "startup"
		app_startup_interface()
		
		// Deactivate instances for better performance
		instance_deactivate_object(obj_deactivate)
		
		return 0
	}
	else
		window_taskbar_progress_state_set(e_window_taskbar_state.NORMAL)
	
	var wid, hei, panelwid;
	wid = load_assets_width
	hei = load_assets_height
	panelwid = 250
	
	var xoff, yoff;
	xoff = floor((window_width/2) - (wid/2))
	yoff = floor((window_height/2) - (hei/2))
	
	content_x = 28
	content_y = 28
	content_width = window_width - 56
	content_height = window_height - 56
	
	draw_box(xoff, yoff, wid, hei, false, c_level_middle, 1)
	
	// Pattern
	var pattern = (setting_theme = theme_light ? 0 : 1);
	draw_sprite_ext(spr_pattern_left, pattern, xoff, yoff, 138 / sprite_get_width(spr_pattern_left), hei / sprite_get_height(spr_pattern_left), 0, c_white, 1)
	
	draw_sprite(spr_load_assets, 0, xoff + panelwid / 2, yoff + 207)
	
	draw_label("Mine-imator " + string(mineimator_version), xoff + panelwid / 2, yoff + 289, fa_middle, fa_bottom, c_text_secondary, a_text_secondary, font_heading)
	draw_label(string(string_upper(mineimator_version_sub)), xoff + panelwid / 2, yoff + 289 + 12, fa_middle, fa_bottom, c_text_secondary, a_text_secondary, font_subheading)
	draw_label(string(string_upper(mineimator_version_extra)), xoff + panelwid / 2, yoff + 289 + (mineimator_version_sub = "" ? 16 : 26), fa_middle, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	draw_label(text_get("startuploadingassets", app.setting_minecraft_assets_version, floor(load_assets_progress * 100)), xoff + panelwid / 2, yoff + 437, fa_middle, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
	
	// Splash
	if (load_assets_splash != null)
		draw_sprite(load_assets_splash, 0, xoff + panelwid, yoff)
	else
		draw_box(xoff + panelwid, yoff, 550, hei, false, c_level_bottom, 1)
	
	if (load_assets_splash = null || sprite_get_width(load_assets_splash) = 550)
		draw_gradient(xoff + panelwid, yoff, shadow_size, hei, c_black, shadow_alpha, 0, 0, shadow_alpha)
	
	// Splash credits
	if (load_assets_credits != "")
		draw_label(text_get("startupsplashauthor", load_assets_credits), xoff + panelwid / 2, yoff + 289 + 31, fa_middle, fa_top, c_text_tertiary, a_text_tertiary, font_caption)
	
	// Loading bar
	draw_box(xoff, yoff + hei - 8, wid, 8, false, c_level_top, .8)
	draw_box(xoff, yoff + hei - 8, wid * load_assets_progress, 8, false, c_accent, 1)
	
	draw_outline(xoff, yoff, wid, hei, 1, c_border, a_border, true)
	draw_dropshadow(xoff, yoff, wid, hei, c_black, 1)
	
	current_step++
}
