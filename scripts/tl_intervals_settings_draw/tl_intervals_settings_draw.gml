/// tl_intervals_settings_draw()

dx = content_x + 8
dy = content_y + 8
dw = settings_menu_w - (8 * 2)

draw_set_font(font_emphasis)
var capwid = text_max_width("timelineintervalsize", "timelineintervaloffset") + 16;

tab_control_dragger()
draw_dragger("timelineintervalsize", dx, dy, 64, timeline_interval_size, .1, 1, no_limit, project_tempo, 1, timeline.tbx_interval_size, action_tl_interval_size, capwid)
tab_next()

tab_control_dragger()
draw_dragger("timelineintervaloffset", dx, dy, 64, timeline_interval_offset, .1, -no_limit, no_limit, 0, 1, timeline.tbx_interval_offset, action_tl_interval_offset, capwid)
tab_next()

settings_menu_w = (capwid + 16 + 64)
settings_menu_h = dy - content_y
