/// menu_quality_settings()

function menu_quality_settings()
{
	var capwid, text;
	
	// Minecraft fog
	draw_set_font(font_label)
	capwid = text_max_width("viewmodefog") + 16 + 24;
	
	tab_control_switch()
	if (draw_switch("viewmodefog", dx, dy, settings_menu_view.fog, null))
		settings_menu_view.fog = !settings_menu_view.fog
	tab_next()
	
	// Render pass preview
	draw_set_font(font_label)
	capwid = max(176, capwid, text_max_width("viewmodepass") + 16)
	text = text_get("viewmodepass" + render_pass_list[|setting_render_pass]);
	
	tab_control_menu()
	draw_button_menu("viewmodepass", e_menu.LIST, dx, dy, dw, 24, setting_render_pass, text, action_setting_render_pass)
	tab_next()
	
	settings_menu_w = (capwid + 24)
}
