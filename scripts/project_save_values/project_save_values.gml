/// project_save_values(timeline, name)
/// @arg timeline
/// @arg name

var tl, name;
tl = argument0
name = argument1

json_export_object_start(name)

	for (var v = 0; v < e_value.amount; v++)
	{
		if (value[v] != tl.value_default[v])
		{
			if (tl_value_is_bool(v))
				json_export_var_bool(values_list[|v], value[v])
			else if (tl_value_is_color(v))
				json_export_var_color(values_list[|v], value[v])
			else
				json_export_var(values_list[|v], tl_value_get_save_id(v, value[v]))
		}
	}
			
json_export_object_done()