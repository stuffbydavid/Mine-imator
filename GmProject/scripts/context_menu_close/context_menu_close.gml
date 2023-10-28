/// context_menu_close()

function context_menu_close()
{
	if (context_menu_name = "")
		return 0
	
	if (!toolbar_menu_active)
	{
		context_menu_name_last = context_menu_name
		context_menu_find_script = null
		context_menu_find_script_name = ""
	
		// Get script of active item in first menu
		var l = context_menu_level[|0];
	
		for (var i = 0; i < ds_list_size(l.level_list.item); i++)
		{
			var item = l.level_list.item[|i];
			if (item.context_menu_active)
			{
				if (item.script = null)
				{
					context_menu_find_script = item.context_menu_script
					context_menu_find_script_name = item.context_menu_name
				}
				else
					context_menu_find_script = item.script
			
				break
			}
		}
	}
	
	if (context_menu_find_script = action_value_cut ||
		context_menu_find_script = action_value_copy)
		context_menu_find_script = action_value_paste
	
	if (context_menu_find_script = action_group_copy ||
		context_menu_find_script = action_group_copy_global)
		context_menu_find_script = action_group_paste
	
	toolbar_menu_active = false
	context_menu_name = ""
	
	context_menu_mouseon = false
	
	context_menu_level_amount = 0
	context_menu_mouseon_level = 0
	ds_list_clear(context_menu_level)
		
	with (obj_context_menu_level)
	{
		list_destroy(level_list)
		instance_destroy()
	}
	
	mouse_left = false
	mouse_left_pressed = false
	mouse_left_double_pressed = false
	mouse_click_count = 0
	
	context_menu_min_x = 0
	context_menu_min_y = 0
	context_menu_max_x = 0
	context_menu_max_y = 0
}
