/// project_save_values(name, array, defaultarray)
/// @arg name
/// @arg array
/// @arg defaultarray

function project_save_values(name, arr, defarr)
{
	json_save_object_start(name)
	
		for (var v = 0; v < e_value.amount; v++)
		{
			if (arr[@ v] != defarr[@ v])
			{
				if (tl_value_is_bool(v))
					json_save_var_bool(value_name_list[|v], arr[@ v])
				else if (tl_value_is_color(v))
					json_save_var_color(value_name_list[|v], arr[@ v])
				else if (tl_value_is_string(v))
					json_save_var(value_name_list[|v], json_string_encode(arr[@ v]))
				else
					json_save_var(value_name_list[|v], tl_value_get_save_id(v, arr[@ v]))
			}
		}
	
	json_save_object_done()
}
