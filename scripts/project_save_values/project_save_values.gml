/// project_save_values(timeline, name)
/// @arg timeline
/// @arg name

var tl, name;
tl = argument0
name = argument1

json_export_object_start(name)

	for (var v = 0; v < e_value.amount; v++)
		if (value[v] != tl.value_default[v])
			json_export_var(values_list[|v], tl_value_save(v, value[v]))
			
json_export_object_done()