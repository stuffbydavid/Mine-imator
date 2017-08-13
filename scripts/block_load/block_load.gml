/// block_load(map)
/// @arg map

var map = argument0;

with (new(obj_block))
{
	// Name
	if (is_string(map[?"name"]))
		name = map[?"name"]
	else
	{
		log("Could not find name for block")
		return null
	}
	
	// Type (overridden by states)
	if (is_string(map[?"type"]))
		type = map[?"type"]
	else
		type = ""
	
	// File
	if (is_string(map[?"file"]))
		file = block_load_state_file(map[?"file"], type)
	else
		file = null
			
	// Brightness (overridden by states)
	if (is_real(map[?"brightness"]))
		brightness = map[?"brightness"]
	else
		brightness = 0
	
	// Read states and their possible values
	states_map = null
	if (is_real(map[?"states"]) && ds_exists(map[?"states"], ds_type_map))
	{
		states_map = ds_map_create()
		var curstate = ds_map_find_first(map[?"states"]);
		while (!is_undefined(curstate))
		{
			with (new(obj_block_state))
			{
				name = curstate
				var valuelist = ds_map_find_value(map[?"states"], curstate);
				value_amount = ds_list_size(valuelist)
				
				for (var v = 0; v < value_amount; v++)
				{
					var curvalue = valuelist[|v];
					value_name[v] = curvalue
					value_file[v] = null
					value_type[v] = ""
					value_brightness[v] = null
					
					if (!is_string(curvalue) && ds_exists(curvalue, ds_type_map))
					{
						// Name
						value_name[v] = curvalue[?"value"]
						
						// File
						if (!is_undefined(curvalue[?"file"]))
							value_file[v] = block_load_state_file(curvalue[?"file"], other.type)
								
						// Type
						if (is_string(curvalue[?"type"]))
							value_type[v] = curvalue[?"type"]
							
						// Brightness
						if (is_real(curvalue[?"brightness"]))
							value_brightness[v] = curvalue[?"brightness"]
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
	
	// Random offset
	if (is_real(map[?"random_offset"]))
		random_offset = map[?"random_offset"]
	else
		random_offset = false
	
	// Wind
	var windmap = map[?"wind"];
	wind_axis = e_vertex_wave.NONE
	wind_zroot = null
	if (is_real(windmap) && ds_exists(windmap, ds_type_map))
	{
		if (is_string(windmap[?"axis"]))
		{
			if (windmap[?"axis"] = "y")
				wind_axis = e_vertex_wave.Z_ONLY
			else
				wind_axis = e_vertex_wave.ALL
		}
		
		if (is_real(windmap[?"yroot"]))
			wind_zroot = windmap[?"yroot"]
	}
	
	// Requires render models
	if (is_real(map[?"require_models"]))
		require_models = map[?"require_models"]
	else
		require_models = false
	
	// Legacy data
	for (var d = 0; d < 16; d++)
	{
		legacy_data_state_map[d] = null
		legacy_data_state[d] = ""
	}
		
	// Read data list into maps
	if (is_real(map[?"legacy_data"]) && ds_exists(map[?"legacy_data"], ds_type_map))
		block_load_legacy_data_map(map[?"legacy_data"], 0, 1)
	
	// Convert maps to strings
	for (var d = 0; d < 16; d++)
	{
		if (legacy_data_state_map[d] != null)
		{
			legacy_data_state[d] = block_vars_map_to_string(legacy_data_state_map[d])
			ds_map_destroy(legacy_data_state_map[d])
		}
	}
	
	return id
}