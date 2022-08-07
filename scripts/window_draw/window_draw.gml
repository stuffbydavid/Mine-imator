/// window_draw()

function window_draw()
{
	if (window_state = "load_assets")
	{
		window_draw_load_assets()
		return 0
	}
	
	if (window_state = "new_assets")
	{
		window_draw_new_assets()
		return 0
	}
	
	if (window_state = "export_movie")
	{
		window_draw_exportmovie()
		return 0
	}
	
	if (window_state = "startup")
	{
		window_draw_startup()
		window_draw_cover()
	}
	else if (window_state = "world_import")
	{
		window_draw_world_import()
		
		toolbar_draw()
		shortcut_bar_draw()
		
		if (menu_popup = null && popup)
			menu_draw()
		
		window_draw_cover()
	}
	else
	{
		panel_area_draw()
		toolbar_draw()
		shortcut_bar_draw()
		bench_draw()
		
		if (menu_popup = null && popup)
			menu_draw()
		
		window_draw_cover()
		window_draw_timeline_move()
	}
	
	window_draw_toasts()
	popup_draw()
	menu_settings_draw()
	if (!(menu_popup = null && popup))
		menu_draw()
	context_menu_draw()
	tip_draw()
	debug_info_draw()
}
