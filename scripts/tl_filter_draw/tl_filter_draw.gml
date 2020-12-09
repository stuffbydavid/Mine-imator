/// tl_filter_draw()

draw_set_font(font_emphasis)

var switchwid, colorwid, px;
switchwid = text_max_width("timelinehideghosts") + 64
colorwid = (24 * 9) - 4

// Color tags
draw_label(text_get("timelinefiltertags"), dx, dy + 9, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_emphasis)
dy += 20

tab_control(20)
for (var i = 0; i <= 8; i++)
{
	px = dx + (24 * i)
	
	draw_box(px, dy, 20, 20, false, setting_theme.accent_list[i], 1)
	
	if (timeline_hide_color_tag[i])
	{
		draw_box(px, dy, 20, 20, false, c_text_tertiary, a_text_tertiary)
		draw_image(spr_icons, icons.CLOSE_SMALL, px + 10, dy + 10, 1, 1, c_background, 1)
	}
	
	if (app_mouse_box(px, dy, 20, 20))
	{
		mouse_cursor = cr_handpoint
		
		if (mouse_left_pressed)
		{
			timeline_hide_color_tag[i] = !timeline_hide_color_tag[i]
			tl_update_list()
		}
	}
	
	colorwid = max(colorwid, text_max_width("contextmenucolor" + string(i)))
}
tab_next()

// Hide ghosts
tab_control_switch()
draw_switch("timelinehideghosts", dx, dy, setting_timeline_hide_ghosts, action_setting_timeline_hide_ghosts, false, "timelinehideghoststip")
tab_next()

settings_menu_w = max(switchwid, colorwid) + 24
