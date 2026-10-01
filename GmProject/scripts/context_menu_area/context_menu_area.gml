/// @desc Checks area for right-click, creates context menu.
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg name
/// @arg [value]
/// @arg [valuetype]
/// @arg [script]
/// @arg [default]

function context_menu_area(xx, yy, wid, hei, name, value = null, valuetype = null, script = null, def = null)
{
	if (app_mouse_box(xx, yy, wid, hei) && mouse_right_pressed)
	{
		if (value != null)
		{
			context_menu_value = value
			context_menu_value_type = valuetype
			context_menu_value_script = script
			context_menu_value_default = def
		}
		else
			context_menu_value = null
		
		// Quick shortcut for value reset
		if (keyboard_check(vk_shift) && value != null && context_menu_value_script != null)
		{
			if (popup_current = popup_armor_editor)
			{
				list_item_script = action_value_reset
				return true
			}
			
			if (valuetype = e_context_type.TIME || valuetype = e_context_type.NUMBER)
				script_execute(script, def, false)
			
			if (valuetype = e_context_type.COLOR)
				script_execute(script, def)
			
			return true
		}
		
		context_menu_close()
		app_mouse_clear()
		
		context_menu_name = name
		context_menu_group = context_menu_group_temp
		
		context_menu_copy_axis_edit = axis_edit
		context_menu_camera_effect_type_edit = camera_effect_type_edit
		
		context_menu_busy_prev = window_busy
		window_busy = "context_menu"
		
		// Get current font
		var font, c;
		font = draw_get_font()
		c = context_menu_add_level(name, mouse_x + 1, mouse_y)
		c.ani = 0.99
		
		if (font != draw_get_font())
			draw_set_font(font)
		
		return true
	}
	
	return false
}
