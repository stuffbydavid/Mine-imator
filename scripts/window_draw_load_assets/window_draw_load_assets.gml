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
	
	// Pattern
	var pattern = (setting_theme = theme_light ? 0 : 1);
	draw_sprite_ext(spr_pattern_left, pattern, 0, 0, 138 / sprite_get_width(spr_pattern_left), 450 / sprite_get_height(spr_pattern_left), 0, c_white, 1)
	
	draw_sprite(spr_load_assets, 0, 95, 207)
	
	draw_label("Mine-imator v" + string(mineimator_version), 95, 289, fa_middle, fa_bottom, c_text_secondary, a_text_secondary, font_heading)
	draw_label(string(string_upper(mineimator_version_extra)), 95, 289 + 14, fa_middle, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	draw_label(text_get("startuploadingassets", floor(load_assets_progress * 100)), 95, 437, fa_middle, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
	
	// Splash
	if (load_assets_splash != null)
		draw_sprite(load_assets_splash, 0, 190, 0)
	//draw_box(190, 0, 550, 450, false, c_level_bottom, 1)
	
	draw_gradient(190, 0, shadow_size, 450, c_black, shadow_alpha, 0, 0, shadow_alpha)
	
	draw_box(0, 450 - 8, 740, 8, false, c_level_top, .8)
	draw_box(0, 450 - 8, 740 * load_assets_progress, 8, false, c_accent, 1)
	
	draw_outline(0, 0, 740, 450, 1, c_border, a_border, true)
	
	current_step++
}
