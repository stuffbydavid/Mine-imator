/// marker_editor_draw()

timeline.tbx_marker_name.text = timeline_marker_edit.name

// Name
tab_control_textfield()
if (draw_textfield("timelinemarkerlabel", dx, dy, settings_menu_w - 24, 24, timeline.tbx_marker_name, null))
	action_tl_marker_edit(timeline.tbx_marker_name.text, timeline_marker_edit.color)
tab_next()

// Color
var text, color;
text = text_get("timelinemarkercolor" + string(timeline_marker_edit.color))
color = setting_theme.accent_list[timeline_marker_edit.color]

tab_control_menu()
draw_button_menu("timelinemarkercolor", e_menu.LIST, dx, dy, settings_menu_w - 24, 24, timeline_marker_edit.color, text, action_tl_marker_color, false, spr_16, null, "", color, 1)
tab_next()

settings_menu_w = 216
