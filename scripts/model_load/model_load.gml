/// model_load(map, directory)
/// @arg map
/// @arg directory

var map, dir;
map = argument0
dir = argument1

with (new(obj_model))
{
	// Name
	if (is_string(map[?"name"]))
		name = map[?"name"]
	else
	{
		log("Could not find name for model")
		return null
	}
	
	// File
	if (is_string(map[?"file"]))
		file = model_file_load(dir + map[?"file"])
	else
		file = null
		
	// Texture
	if (is_string(map[?"texture"]))
		texture_name = map[?"texture"]
	else
		texture_name = ""
		
	// Read states and their possible values
	states_map = null
	if (is_real(map[?"states"]) && ds_exists(map[?"states"], ds_type_map))
	{
		states_map = ds_map_create()
		var curstate = ds_map_find_first(map[?"states"]);
		while (!is_undefined(curstate))
		{
			with (new(obj_model_state))
			{
				name = curstate
				var valuelist = ds_map_find_value(map[?"states"], curstate);
				value_amount = ds_list_size(valuelist)
				
				for (var v = 0; v < value_amount; v++)
				{
					var curvalue = valuelist[|v];
					value_name[v] = curvalue[?"value"]
					value_file[v] = null
					value_texture_name[v] = ""
					
					// File
					if (!is_undefined(curvalue[?"file"]))
						value_file[v] = model_file_load(dir + curvalue[?"file"])
								
					// Texture
					if (is_string(curvalue[?"texture"]))
						value_texture_name[v] = curvalue[?"texture"]
				}
				
				other.states_map[?curstate] = id
				curstate = ds_map_find_next(map[?"states"], curstate)
			}
		}
	}
	
	// Default state
	if (is_string(map[?"default_state"]))
		default_state = map[?"default_state"]
	else
		default_state = ""
		
	return id
}