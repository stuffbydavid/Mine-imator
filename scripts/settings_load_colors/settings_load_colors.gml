/// settings_load_colors(map)
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0
	
setting_color_interface = json_read_color(map[?"interface"], setting_color_interface)
setting_color_background = json_read_color(map[?"background"], setting_color_background)
setting_color_background_scrollbar = json_read_color(map[?"background_scrollbar"], setting_color_background_scrollbar)
setting_color_text = json_read_color(map[?"text"], setting_color_text)
setting_color_tips = json_read_color(map[?"tips"], setting_color_tips)
setting_color_tips_text = json_read_color(map[?"tips_text"], setting_color_tips_text)
setting_color_buttons = json_read_color(map[?"buttons"], setting_color_buttons)
setting_color_buttons_pressed = json_read_color(map[?"buttons_pressed"], setting_color_buttons_pressed)
setting_color_buttons_text = json_read_color(map[?"buttons_text"], setting_color_buttons_text)
setting_color_boxes = json_read_color(map[?"boxes"], setting_color_boxes)
setting_color_boxes_pressed = json_read_color(map[?"boxes_pressed"], setting_color_boxes_pressed)
setting_color_boxes_text = json_read_color(map[?"boxes_text"], setting_color_boxes_text)
setting_color_highlight = json_read_color(map[?"highlight"], setting_color_highlight)
setting_color_highlight_text = json_read_color(map[?"highlight_text"], setting_color_highlight_text)
setting_color_timeline = json_read_color(map[?"timeline"], setting_color_timeline)
setting_color_timeline_text = json_read_color(map[?"timeline_text"], setting_color_timeline_text)
setting_color_timeline_select = json_read_color(map[?"timeline_select"], setting_color_timeline_select)
setting_color_alerts = json_read_color(map[?"alerts"], setting_color_alerts)
setting_color_alerts_text = json_read_color(map[?"alerts_text"], setting_color_alerts_text)
