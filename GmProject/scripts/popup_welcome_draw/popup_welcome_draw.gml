/// popup_welcome_draw()

function popup_welcome_draw()
{
	// Info
	draw_set_font(font_value)
	var text = string_limit_ext(text_get("welcomedescription"), (dw - 40) + 8, no_limit);
	draw_label(text, floor(dx + dw/2), dy, fa_middle, fa_top, c_text_main, a_text_main, font_value)
	
	dy += string_height(text) + 19
	
	tab_control_button_label()
	if (draw_button_label("welcomecontinue", content_x + content_width - 12, dy, null, null, e_button.PRIMARY, null, fa_right))
	{
		settings_save()
		popup_close()
	}
	tab_next()
}