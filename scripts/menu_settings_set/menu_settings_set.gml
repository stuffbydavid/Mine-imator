/// menu_settings_set(x, y, name, buttonheight)
/// @arg x
/// @arg y
/// @arg name
/// @arg buttonheight

function menu_settings_set(xx, yy, name, buttonheight)
{
	settings_menu_busy_prev = window_busy
	window_busy = "settingsmenu"
	window_focus = ""
	app_mouse_clear()
	
	settings_menu_name = name
	settings_menu_ani = 0
	settings_menu_ani_type = "show"
	settings_menu_steps = 0
	
	settings_menu_sortlist = ""
	
	// Init
	settings_menu_scroll.value_goal = 0
	settings_menu_scroll.value = 0
	settings_menu_primary = false
	settings_menu_x = xx
	settings_menu_y = yy
	settings_menu_h_max = null
	settings_menu_above = false
	
	settings_menu_list = list_init(settings_menu_name)
	settings_menu_amount = ds_list_size(settings_menu_list.item)
	
	list_update_width(settings_menu_list)
	settings_menu_w = (settings_menu_list.width + 12)
	
	if ((settings_menu_x + (settings_menu_w/2)) > window_width)
		settings_menu_x += window_width - (settings_menu_x + (settings_menu_w/2))
	
	settings_menu_button_h = buttonheight
	settings_menu_button_w = 16
}
