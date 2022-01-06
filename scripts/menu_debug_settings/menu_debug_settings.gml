/// menu_debug_settings()

function menu_debug_settings()
{
	draw_set_font(font_label)
	var switchwid = text_max_width("viewboxes", "viewcascades") + 16 + 24
	
	tab_control_dragger()
	if (draw_switch("viewboxes", dx, dy, settings_menu_view.boxes, null))
		settings_menu_view.boxes = !settings_menu_view.boxes
	tab_next()
	
	tab_control_dragger()
	if (draw_switch("viewcascades", dx, dy, settings_menu_view.cascades, null))
	{
		settings_menu_view.cascades = !settings_menu_view.cascades
		render_samples = -1
	}
	tab_next()
	
	settings_menu_w = (switchwid + 24)
}
