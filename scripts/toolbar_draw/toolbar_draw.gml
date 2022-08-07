/// toolbar_draw()

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
	
	var capwid, padding;
	padding = 0
	
	draw_set_font(font_value)
	
	if (window_state = "world_import")
	{
		capwid = string_width(text_get("toolbarcancel")) + 16
		if (toolbar_draw_button("toolbarcancel", dx, dy, capwid, false))
		{
			world_import_cancel()
			app_mouse_clear()
		}
		
		dx += capwid + 4
		draw_divide_vertical(dx, content_y, content_height)
		dx += 4
	}
	
	capwid = string_width(text_get("toolbarfile")) + 16
	toolbar_draw_button("toolbarfile", dx, dy, capwid)
	dx += capwid + padding
	
	if (window_state = "")
	{
		capwid = string_width(text_get("toolbaredit")) + 16
		toolbar_draw_button("toolbaredit", dx, dy, capwid)
		dx += capwid + padding
		
		capwid = string_width(text_get("toolbarrender")) + 16
		toolbar_draw_button("toolbarrender", dx, dy, capwid)
		dx += capwid + padding
	}
	
	capwid = string_width(text_get("toolbarview")) + 16
	toolbar_draw_button("toolbarview", dx, dy, capwid)
	dx += capwid + padding
	
	capwid = string_width(text_get("toolbarhelp")) + 16
	toolbar_draw_button("toolbarhelp", dx, dy, capwid)
	dx += capwid + padding
	
	dx += 8
	draw_label(text_get("toolbarbackup"), dx, dy + 22, fa_left, fa_bottom, c_text_secondary, a_text_secondary * clamp(backup_text_ani, 0, 1), font_value)
	
	// "Simple mode" button label
	if (!setting_advanced_mode)
	{
		if (draw_button_label("toolbarsimplemode", content_x + content_width - 10, dy, null, null, e_button.TOOLBAR, null, fa_right))
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
