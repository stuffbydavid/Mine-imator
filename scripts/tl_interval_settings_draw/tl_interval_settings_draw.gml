/// tl_interval_settings_draw()

function tl_interval_settings_draw()
{
	draw_set_font(font_label)
	
	tab_control_dragger()
	draw_dragger("timelineintervalssize", dx, dy, dragger_width, timeline_interval_size, .1, 1, no_limit, project_tempo, 1, timeline.tbx_interval_size, action_tl_interval_size)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("timelineintervalsoffset", dx, dy, dragger_width, timeline_interval_offset, .1, -no_limit, no_limit, 0, 1, timeline.tbx_interval_offset, action_tl_interval_offset)
	tab_next()
	
	settings_menu_w = (text_max_width("timelineintervalssize", "timelineintervalsoffset") + 16 + dragger_width) + 24
}
