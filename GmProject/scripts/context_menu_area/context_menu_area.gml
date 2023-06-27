/// context_menu_area(x, y, width, height, name, [value, valuetype, script, default])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg name
/// @arg [value
/// @arg valuetype
/// @arg script
/// @arg default]
/// @desc Checks area for right-click, creates context menu

function context_menu_area()
{
	var xx, yy, wid, hei, name, font;
	xx = argument[0]
	yy = argument[1]
	wid = argument[2]
	hei = argument[3]
	name = argument[4]
	
	if (app_mouse_box(xx, yy, wid, hei) && mouse_right_released)
	{
		if (argument_count > 5)
		{
			context_menu_value = argument[5]
			context_menu_value_type = argument[6]
			
			context_menu_value_script = argument[7]
			context_menu_value_default = argument[8]
		}
		
		// Quick shortcut for value reset
		if (keyboard_check(vk_shift) && argument_count > 5)
		{
			list_item_script = action_value_reset
			return true
		}
		
		context_menu_close()
		app_mouse_clear()
		
		context_menu_name = name
		context_menu_copy_axis_edit = axis_edit
		context_menu_busy_prev = window_busy
		window_busy = "contextmenu"
		context_menu_group = context_menu_group_temp
		
		// Get current font
		font = draw_get_font()
		context_menu_add_level(name, mouse_x + 1, mouse_y)
		
		if (font != draw_get_font())
			draw_set_font(font)
		
		return true
	}
}
