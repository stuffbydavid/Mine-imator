/// menu_snap_settings()

function menu_snap_settings()
{
	draw_set_font(font_label)
	var draggerwid, switchwid;
	draggerwid = text_max_width("viewsnapmove", "viewsnaprotate", "viewsnapscale") + 16 + dragger_width
	switchwid = text_max_width("viewsnapabsolute") + 28 + 16 + 24
	
	tab_control_dragger()
	draw_dragger("viewsnapmove", dx, dy, dragger_width, setting_snap_size_position, 0.01, snap_min, no_limit, 1, snap_min, tbx_snap_position, action_setting_snap_size_position)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("viewsnaprotate", dx, dy, dragger_width, setting_snap_size_rotation, 0.01, snap_min, no_limit, 15, snap_min, tbx_snap_rotation, action_setting_snap_size_rotation)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("viewsnapscale", dx, dy, dragger_width, setting_snap_size_scale, 0.01, snap_min, no_limit, 0.25, snap_min, tbx_snap_scale, action_setting_snap_size_scale)
	tab_next()
	
	draw_divide(content_x, dy, content_width)
	dy += 8
	
	tab_control_switch()
	draw_switch("viewsnapabsolute", dx, dy, setting_snap_absolute, action_setting_snap_absolute, "viewsnapabsolutetip")
	tab_next()
	
	settings_menu_w = (max(draggerwid, switchwid) + 24)
}
