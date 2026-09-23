/// menu_overlay_settings()

function menu_overlay_settings()
{
	draw_set_font(font_label)
	var switchwid = text_max_width("viewsnapabsolute") + 28 + 16 + 24
	
	tab_control_switch()
	draw_switch("viewoverlaycontrols", dx, dy, setting_overlay_view_controls, action_setting_overlay_view_controls)
	tab_next()
	
	tab_control_switch()
	draw_switch("viewoverlayshapes", dx, dy, setting_overlay_view_shapes, action_setting_overlay_view_shapes)
	tab_next()
	
	tab_control_switch()
	draw_switch("viewoverlayguides", dx, dy, setting_overlay_view_guides, action_setting_overlay_view_guides, "viewoverlayguidestip")
	tab_next()
	
	settings_menu_w = (switchwid + 24)
}