/// list_init_end()

function list_init_end()
{
	var list = list_edit;
	var name = "";
	
	if (menu_filter != "")
	{
		var filter = false;
		
		// Check if filter string is in any of item names
		for (var i = 0; i < ds_list_size(list.item); i++)
		{
			name = string_lower(list.item[|i].name)
			
			if (string_contains(name, string_lower(menu_filter)))
			{
				filter = true
				break
			}
		}
		
		// Remove items
		if (filter)
		{
			for (var i = 0; i < ds_list_size(list.item); i++)
			{
				name = string_lower(list.item[|i].name)
				name = string_replace_all(name, "normal", string_lower(menu_filter_normal))
				
				if (!string_contains(name, string_lower(menu_filter)))
				{
					instance_destroy(list.item[|i])
					ds_list_delete(list.item, i)
					i--
				}
			}
		}
	}
	
	// Search filter
	if (menu_search != "")
	{
		for (var i = 0; i < ds_list_size(list.item); i++)
		{
			name = string_lower(list.item[|i].name)
			
			if (!string_contains(name, string_lower(menu_search)))
			{
				instance_destroy(list.item[|i])
				ds_list_delete(list.item, i)
				i--
			}
		}
	}
	
	list_update_width(list)
	
	if (ds_list_size(list.item) > 0 && list.item[|0].divider)
		list.item[|0].divider = false
	
	list_edit = null
	
	return list
}
