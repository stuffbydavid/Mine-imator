/// block_load(map, typemap)
/// @arg map
/// @arg typemap

var map, typemap;
map = argument0
typemap = argument1

with (new(obj_block))
{
	// Name
	if (is_string(map[?"name"]))
		name = map[?"name"]
	else
	{
		log("Missing parameter \"name\"")
		return null
	}
	
	if (dev_mode_check_names && !text_exists("block" + name))
		log("block/" + name + dev_mode_name_translation_message)
	
	// Type (overridden by states)
	if (is_string(map[?"type"]))
		type = map[?"type"]
	else
		type = ""
	
	// File
	if (is_string(map[?"file"]))
		file = block_load_state_file(blockstates_directory + map[?"file"], type)
	else
		file = null
			
	// Brightness (overridden by states)
	if (is_real(map[?"brightness"]))
		brightness = map[?"brightness"]
	else
		brightness = 0
	
	// Read states and their possible values
	states_map = null
	if (ds_map_valid(map[?"states"]))
	{
		states_map = ds_map_create()
		var curstate = ds_map_find_first(map[?"states"]);
		
		while (!is_undefined(curstate))
		{
			if (dev_mode_check_names && !text_exists("blockstate" + curstate))
				log("block/state/" + curstate + dev_mode_name_translation_message)
				
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
					
					if (ds_map_valid(curvalue))
					{
						// Name
						value_name[v] = curvalue[?"value"]
						
						// File
						if (!is_undefined(curvalue[?"file"]))
							value_file[v] = block_load_state_file(blockstates_directory + curvalue[?"file"], other.type)
								
						// Type
						if (is_string(curvalue[?"type"]))
							value_type[v] = curvalue[?"type"]
							
						// Brightness
						if (is_real(curvalue[?"brightness"]))
							value_brightness[v] = curvalue[?"brightness"]
					}
					
					if (dev_mode_check_names && string_length(value_name[v]) > 3 && !text_exists("blockstatevalue" + value_name[v]))
						log("block/state/value/" + value_name[v] + dev_mode_name_translation_message)
				}
				
				other.states_map[?curstate] = id
				curstate = ds_map_find_next(map[?"states"], curstate)
			}
		}
	}
	
	// Default state
	if (is_string(map[?"default_state"]))
		default_state = string_get_state_vars(map[?"default_state"])
	else
		default_state = array()
	
	// Random offset
	if (is_real(map[?"random_offset"]))
		random_offset = map[?"random_offset"]
	else
		random_offset = false
	
	// Wind
	var windmap = map[?"wind"];
	wind_axis = e_vertex_wave.NONE
	wind_zmin = null
	if (ds_map_valid(windmap))
	{
		if (is_string(windmap[?"axis"]))
		{
			if (windmap[?"axis"] = "y")
				wind_axis = e_vertex_wave.Z_ONLY
			else
				wind_axis = e_vertex_wave.ALL
		}
		
		if (is_real(windmap[?"ymin"]))
			wind_zmin = windmap[?"ymin"]
	}
	
	// Requires render models
	if (is_real(map[?"require_models"]))
		require_models = map[?"require_models"]
	else
		require_models = false
	
	// Has timeline
	var timelinemap = map[?"timeline"];
	timeline = false
	if (ds_map_valid(timelinemap))
		block_load_timeline(timelinemap, typemap[?timelinemap])
	
	// Legacy data
	for (var d = 0; d < 16; d++)
		legacy_data_state[d] = array()
		
	// Read data list into maps
	if (ds_map_valid(map[?"legacy_data"]))
		block_load_legacy_data_map(map[?"legacy_data"], 0, 1)
	
	return id
}