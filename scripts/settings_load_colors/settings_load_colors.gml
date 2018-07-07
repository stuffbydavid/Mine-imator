/// settings_load_colors(map)
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0
	
setting_color_interface = value_get_color(map[?"interface"], setting_color_interface)
setting_color_background = value_get_color(map[?"background"], setting_color_background)
setting_color_background_scrollbar = value_get_color(map[?"background_scrollbar"], setting_color_background_scrollbar)
setting_color_text = value_get_color(map[?"text"], setting_color_text)
setting_color_tips = value_get_color(map[?"tips"], setting_color_tips)
setting_color_tips_text = value_get_color(map[?"tips_text"], setting_color_tips_text)
setting_color_buttons = value_get_color(map[?"buttons"], setting_color_buttons)
setting_color_buttons_pressed = value_get_color(map[?"buttons_pressed"], setting_color_buttons_pressed)
setting_color_buttons_text = value_get_color(map[?"buttons_text"], setting_color_buttons_text)
setting_color_boxes = value_get_color(map[?"boxes"], setting_color_boxes)
setting_color_boxes_pressed = value_get_color(map[?"boxes_pressed"], setting_color_boxes_pressed)
setting_color_boxes_text = value_get_color(map[?"boxes_text"], setting_color_boxes_text)
setting_color_highlight = value_get_color(map[?"highlight"], setting_color_highlight)
setting_color_highlight_text = value_get_color(map[?"highlight_text"], setting_color_highlight_text)
setting_color_timeline = value_get_color(map[?"timeline"], setting_color_timeline)
setting_color_alerts = value_get_color(map[?"alerts"], setting_color_alerts)
setting_color_alerts_text = value_get_color(map[?"alerts_text"], setting_color_alerts_text)
setting_color_timeline_text = value_get_color(map[?"timeline_text"], setting_color_timeline_text)
setting_color_timeline_select = value_get_color(map[?"timeline_select"], setting_color_timeline_select)
setting_color_timeline_marks = value_get_color(map[?"timeline_marks"], setting_color_timeline_marks)
setting_color_timeline_select_box = value_get_color(map[?"timeline_select_box"], setting_color_timeline_select_box)