/// project_load_values(map, array)
/// @arg map
/// @arg array

function project_load_values(map, arr)
{
	var key = ds_map_find_first(map);
	
	while (!is_undefined(key))
	{
		var index = ds_list_find_index(value_name_list, project_load_values_update_name(key));
		
		if (index >= 0)
		{
			if (tl_value_is_bool(index))
				arr[@ index] = value_get_real(map[?key], arr[@ index])
			else if (tl_value_is_color(index))
				arr[@ index] = value_get_color(map[?key], arr[@ index])
			else if (tl_value_is_string(index))
				arr[@ index] = value_get_string(map[?key], arr[@ index])
			else if (map[?key] = "null")
				arr[@ index] = null
			else
				arr[@ index]= map[?key]
		}
		
		key = ds_map_find_next(map, key)
	}
}
