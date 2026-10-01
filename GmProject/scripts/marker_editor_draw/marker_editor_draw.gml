function marker_editor_draw()
{
	timeline.tbx_marker_name.text = timeline_marker_edit.name
	
	// Name
	tab_control_textfield()
	if (draw_textfield("timeline/marker/label", dx, dy, settings_menu_w - 24, 24, timeline.tbx_marker_name, null))
		action_tl_marker_edit(timeline.tbx_marker_name.text, timeline_marker_edit.color)
	tab_next()
	
	// Color
	var color;
	content_text = text_get("timeline/marker/color/" + string(timeline_marker_edit.color))
	color = setting_theme.accent_list[timeline_marker_edit.color]
	
	tab_control_menu()
	draw_button_menu("timeline/marker/color", e_menu.LIST, dx, dy, settings_menu_w - 24, 24, timeline_marker_edit.color, content_text, action_tl_marker_color, false, spr_16, null, "", color, 1)
	tab_next()
	
	settings_menu_w = 216
}
