function toolbar_draw()
{
	content_x = 0
	content_y = 0
	content_width = window_width
	content_height = toolbar_size
	content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	
	dx = content_x + 10
	dy = content_y
	
	// Background
	draw_box(content_x, content_y, content_width, content_height, false, c_level_top, 1)
	draw_divide(content_x, content_y + content_height, content_width)
	draw_gradient(content_x, content_y + content_height, content_width, shadow_size, c_black, shadow_alpha, shadow_alpha, 0, 0)
	
	var padding = 0;
	
	draw_set_font(font_value)
	
	// File
	content_capwid = string_width(text_get("toolbar/file")) + 16
	toolbar_draw_button("toolbar/file", dx, dy, content_capwid)
	
	dx += content_capwid + padding
	
	if (window_state = "")
	{
		content_capwid = string_width(text_get("toolbar/edit")) + 16
		toolbar_draw_button("toolbar/edit", dx, dy, content_capwid)
		dx += content_capwid + padding

		// Render
		content_capwid = string_width(text_get("toolbar/render")) + 16
		toolbar_draw_button("toolbar/render", dx, dy, content_capwid)
		dx += content_capwid + padding
	}
	
	// View
	content_capwid = string_width(text_get("toolbar/view")) + 16
	toolbar_draw_button("toolbar/view", dx, dy, content_capwid)
	dx += content_capwid + padding
	
	// Help
	content_capwid = string_width(text_get("toolbar/help")) + 16
	toolbar_draw_button("toolbar/help", dx, dy, content_capwid)
	dx += content_capwid + padding
	
	dx += 8
	draw_label(text_get("toolbar/backup"), dx, dy + 22, fa_left, fa_bottom, c_text_secondary, a_text_secondary * clamp(backup_text_ani, 0, 1), font_value)
	
	// "Simple mode" button label
	if (!setting_advanced_mode)
	{
		if (draw_button_label("toolbar/simple_mode", content_x + content_width - 10, dy, null, null, e_button.TOOLBAR, null, fa_right))
		{
			if (trial_version)
			{
				popup_show(popup_upgrade)
				popup_upgrade.page = 1
				popup_upgrade.open_advanced = true
			}
			else
				popup_show(popup_advanced)
		}
	}
}
