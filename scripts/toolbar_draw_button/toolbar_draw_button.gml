/// toolbar_draw_button(name, x, y, width)
/// @arg name
/// @arg x
/// @arg y
/// @arg width

function toolbar_draw_button(name, xx, yy, wid)
{
	var trigger, font;
	trigger = false
	
	if (window_busy = "contextmenu")
		window_busy = ""
	
	if (draw_button_label(name, xx, yy, wid, null, e_button.TOOLBAR, null))
		trigger = true
	
	if (context_menu_name != "" && context_menu_name != name && app_mouse_box(xx, yy, wid, 28) && toolbar_menu_active)
		trigger = true
	
	if (trigger)
	{
		context_menu_close()
		app_mouse_clear()
		
		toolbar_menu_active = true
		context_menu_name = name
		context_menu_copy_axis_edit = axis_edit
		context_menu_busy_prev = window_busy
		window_busy = "contextmenu"
		context_menu_group = context_menu_group_temp
		
		// Get current font
		font = draw_get_font()
		
		if (argument_count > 5)
		{
			context_menu_value = argument[5]
			context_menu_value_type = argument[6]
			
			context_menu_value_script = argument[7]
			context_menu_value_default = argument[8]
		}
		
		context_menu_add_level(name, xx - 1, yy + toolbar_size - 1)
		
		if (font != draw_get_font())
			draw_set_font(font)
	}
	
	if (context_menu_name = name)
		current_mcroani.value = true
	
	if (context_menu_name != "")
		window_busy = "contextmenu"
}
