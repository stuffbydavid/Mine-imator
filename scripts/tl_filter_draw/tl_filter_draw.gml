/// tl_filter_draw()

draw_set_font(font_emphasis)
var switchwid = text_max_width("timelinehideghosts") + 16 + 24;

tab_control_switch()
draw_switch("timelinehideghosts", dx, dy, setting_timeline_hide_ghosts, action_setting_timeline_hide_ghosts, false)
tab_next()

settings_menu_w = max(switchwid) + 24
