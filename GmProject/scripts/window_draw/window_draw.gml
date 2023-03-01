/// window_draw()

function window_draw()
{
	// app_event_draw is executed once per window every step, check which window is current
	switch (window_get_current())
	{
		case e_window.MAIN:
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
			
			if (window_state = "export_movie" || window_state = "export_image")
			{
				window_draw_export()
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
			break;
		}
		
		case e_window.VIEW_SECOND:
		{
			view_draw(view_second)
			if (menu_popup = null && popup)
				menu_draw()
			window_set_caption(view_second.title + " - Mine-imator")
			break
		}
		
		case e_window.TIMELINE:
		{
			panel_window_obj.tab_list[0] = timeline
			panel_window_obj.tab_list_amount = 1
			panel_draw(panel_window_obj)
			if (menu_popup = null && popup)
				menu_draw()
			window_set_caption(text_get("tabtimeline") + " - Mine-imator")
			break
		}
	}
	
	// Common to all windows
	menu_settings_draw()
	if (!(menu_popup = null && popup))
		menu_draw()
	context_menu_draw()
	tip_draw()
	debug_info_draw()
}
