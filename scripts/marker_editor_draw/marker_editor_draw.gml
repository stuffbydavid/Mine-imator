/// marker_editor_draw()

dx = content_x + 12
dy = content_y + 12

timeline.tbx_markername.text = timeline_marker_edit.name

// Name
tab_control_menu(28)
if (draw_textfield("timelinemarkerlabel", dx, dy, settings_menu_w - 24, 28, timeline.tbx_markername, null))
	action_tl_marker_edit(timeline.tbx_markername.text, timeline_marker_edit.color)
tab_next()

// Color
var text, color;
text = text_get("timelinemarkercolor" + string(timeline_marker_edit.color))
color = setting_theme.accent_list[timeline_marker_edit.color]

tab_control_menu(28)
draw_button_menu("timelinemarkercolor", e_menu.LIST, dx, dy, settings_menu_w - 24, 28, timeline_marker_edit.color, text, action_tl_marker_color, false, spr_16, null, "", color, 1)
tab_next()
//draw_label(text_get("timelinemarkercolors"), dx, dy + 4, fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 4

/*
var colorsx;
colorsx = dx

for (var i = 0; i <= 8; i++)
{
	if (app_mouse_box(colorsx, dy, 20, 20))
	{
		mouse_cursor = cr_handpoint
		
		if (mouse_left_released)
			action_tl_marker_edit(timeline_marker_edit.name, i)
	}
	
	draw_box(colorsx, dy, 20, 20, false, setting_theme.accent_list[i], 1)
	colorsx += 24
}

dy += 20 + 16
*/

settings_menu_w = 216
settings_menu_h = dy - content_y
