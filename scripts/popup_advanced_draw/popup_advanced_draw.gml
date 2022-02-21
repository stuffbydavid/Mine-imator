/// popup_advanced_draw()

function popup_advanced_draw()
{
	// Info
	draw_set_font(font_value)
	var text = string_limit_ext(text_get("advancedinfo"), (dw - 40) + 8, no_limit);
	draw_label(text, floor(dx + dw/2), dy, fa_middle, fa_top, c_text_main, a_text_main, font_value)
	
	dy += string_height(text) + 19
	
	draw_set_font(font_button)
	var buttonx = string_width(text_get("advancedenable")) + button_padding;
	
	tab_control_button_label()
	
	// Enabled advanced mode
	if (draw_button_label("advancedenable", dx + dw - buttonx, dy))
	{
		action_setting_program_mode(true)
		popup_close()
	}
	
	// Not now
	buttonx += 12 + (string_width(text_get("advancednotnow")) + button_padding)
	if (draw_button_label("advancednotnow", dx + dw - buttonx, dy, null, null, e_button.SECONDARY))
		popup_close()
	
	tab_next()
}
