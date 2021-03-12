/// tl_settings_draw()

draw_set_font(font_emphasis)
var draggerwid, switchwid;
draggerwid = text_max_width("timelineintervalsize", "timelineintervaloffset") + 16
switchwid = text_max_width("timelineintervalshow", "timelinecompact") + 16 + 24

// Intervals
tab_control_switch()
draw_switch("timelineintervalshow", dx, dy, timeline_intervals_show, action_tl_intervals_show)
tab_next()

tab_control_dragger()
draw_dragger("timelineintervalsize", dx, dy, dragger_width, timeline_interval_size, .1, 1, no_limit, project_tempo, 1, timeline.tbx_interval_size, action_tl_interval_size, draggerwid)
tab_next()

tab_control_dragger()
draw_dragger("timelineintervaloffset", dx, dy, dragger_width, timeline_interval_offset, .1, -no_limit, no_limit, 0, 1, timeline.tbx_interval_offset, action_tl_interval_offset, draggerwid)
tab_next()

// Timeline list
draw_divide(content_x, dy, settings_menu_w)
dy += 4

tab_control_switch()
draw_switch("timelinemarkers", dx, dy, timeline_show_markers, action_tl_markers_show)
tab_next()

tab_control_switch()
draw_switch("timelinecompact", dx, dy, setting_timeline_compact, action_setting_timeline_compact)
tab_next()

settings_menu_w = max(draggerwid + dragger_width, switchwid) + 24
