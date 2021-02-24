/// menu_snap_settings()

draw_set_font(font_emphasis)
var draggerwid, switchwid, capwid;
draggerwid = text_max_width("viewsnapmove", "viewsnaprotate", "viewsnapscale") + 16
switchwid = text_max_width("viewsnapabsolute") + 16 + 24
capwid = max(draggerwid, settings_menu_w - (64 + 24))

tab_control_dragger()
draw_dragger("viewsnapmove", dx, dy, 64, setting_snap_size_position, 0.01, snap_min, no_limit, 1, snap_min, tbx_snap_position, action_setting_snap_size_position, capwid)
tab_next()

tab_control_dragger()
draw_dragger("viewsnaprotate", dx, dy, 64, setting_snap_size_rotation, 0.01, snap_min, no_limit, 15, snap_min, tbx_snap_rotation, action_setting_snap_size_rotation, capwid)
tab_next()

tab_control_dragger()
draw_dragger("viewsnapscale", dx, dy, 64, setting_snap_size_scale, 0.01, snap_min, no_limit, 1, snap_min, tbx_snap_scale, action_setting_snap_size_scale, capwid)
tab_next()

draw_divide(content_x, dy, content_width)
dy += 8

tab_control_switch()
draw_switch("viewsnapabsolute", dx, dy, setting_snap_absolute, action_setting_snap_absolute, true)
tab_next()

settings_menu_w = (max(draggerwid + 64, switchwid) + 24)