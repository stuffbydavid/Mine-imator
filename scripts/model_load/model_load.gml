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
	{
		texture_name_map = ds_map_create()
		texture_name_map[?""] = map[?"texture"]
	}
	else if (ds_map_valid(map[?"texture"]))
	{
		texture_name_map = ds_map_create()
		ds_map_copy(texture_name_map, map[?"texture"])
	}
	else
		texture_name_map = null
		
	// Read states and their possible values
	states_map = null
	if (ds_map_valid(map[?"states"]))
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
					value_texture_name_map[v] = null
					
					// File
					if (!is_undefined(curvalue[?"file"]))
						value_file[v] = model_file_load(dir + curvalue[?"file"])
								
					// Texture
					if (is_string(curvalue[?"texture"]))
					{
						var texnamemap = ds_map_create();
						texnamemap[?""] = curvalue[?"texture"]
						value_texture_name_map[v] = texnamemap
					}
					else if (ds_map_valid(curvalue[?"texture"]))
					{
						var texnamemap = ds_map_create();
						ds_map_merge(texnamemap, curvalue[?"texture"], true)
						value_texture_name_map[v] = texnamemap
					}
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