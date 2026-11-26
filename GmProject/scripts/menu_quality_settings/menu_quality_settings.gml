function menu_quality_settings()
{
	// Render pass preview
	draw_set_font(font_label)
	content_capwid = max(176, text_max_width("view/renderer/pass") + 16)
	content_text = text_get("view/renderer/pass/" + render_pass_list[|project_render_pass])
	
	tab_control_menu()
	draw_button_menu("view/renderer/pass", e_menu.LIST, dx, dy, dw, 24, project_render_pass, content_text, action_project_render_pass)
	tab_next()
	
	settings_menu_w = (content_capwid + 24)
}
