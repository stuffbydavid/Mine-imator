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
		window_state = "startup"
		app_startup_interface()
		
		// Deactivate instances for better performance
		instance_deactivate_object(obj_deactivate)
		
		return 0
	}
	
	var xoff, yoff;
	xoff = floor((window_width/2) - (740/2))
	yoff = floor((window_height/2) - (450/2))
	
	content_x = 28
	content_y = 28
	content_width = window_width - 56
	content_height = window_height - 56
	
	draw_box(xoff, yoff, 740, 450, false, c_level_middle, 1)
	
	// Pattern
	var pattern = (setting_theme = theme_light ? 0 : 1);
	draw_sprite_ext(spr_pattern_left, pattern, xoff, yoff, 138 / sprite_get_width(spr_pattern_left), 450 / sprite_get_height(spr_pattern_left), 0, c_white, 1)
	
	draw_sprite(spr_load_assets, 0, xoff + 95, yoff + 207)
	
	draw_label("Mine-imator v" + string(mineimator_version), xoff + 95, yoff + 289, fa_middle, fa_bottom, c_text_secondary, a_text_secondary, font_heading)
	draw_label(string(string_upper(mineimator_version_extra)), xoff + 95, yoff + 289 + 14, fa_middle, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
	draw_label(text_get("startuploadingassets", floor(load_assets_progress * 100)), xoff + 95, yoff + 437, fa_middle, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
	
	// Splash
	if (load_assets_splash != null)
		draw_sprite(load_assets_splash, 0, xoff + 190, yoff)
	else
		draw_box(xoff + 190, yoff, 550, 450, false, c_level_bottom, 1)
	
	if (load_assets_splash = null || sprite_get_width(load_assets_splash) = 550)
		draw_gradient(xoff + 190, yoff, shadow_size, 450, c_black, shadow_alpha, 0, 0, shadow_alpha)
	
	// Splash credits
	if (load_assets_credits != "")
		draw_label(load_assets_credits, xoff + 95, yoff + 289 + 31, fa_middle, fa_top, c_text_tertiary, a_text_tertiary, font_credits)
	
	draw_box(xoff, yoff + 450 - 8, 740, 8, false, c_level_top, .8)
	draw_box(xoff, yoff + 450 - 8, 740 * load_assets_progress, 8, false, c_accent, 1)
	
	draw_outline(xoff, yoff, 740, 450, 1, c_border, a_border, true)
	draw_dropshadow(xoff, yoff, 740, 450, c_black, 1)
	
	current_step++
}
