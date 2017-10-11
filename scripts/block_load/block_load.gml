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
	
	if (dev_mode_debug_names && !text_exists("block" + name))
		log("block/" + name + dev_mode_name_translation_message)
	
	// Type (overridden by states)
	if (is_string(map[?"type"]))
	{
		type = map[?"type"]
		set_script = asset_get_index("block_set_" + type)
		generate_script = asset_get_index("block_generate_" + type)
	}
	else
	{
		type = ""
		set_script = null
		generate_script = null
	}
	
	// File
	if (is_string(map[?"file"]))
		filename = map[?"file"]
	else
		filename = ""
			
	// Brightness (overridden by states)
	if (is_real(map[?"brightness"]))
		brightness = map[?"brightness"]
	else
		brightness = 0
	
	// Read states and their possible values
	states_map = null
	state_id_amount = 1
	if (ds_map_valid(map[?"states"]))
	{
		states_map = ds_map_create()
		
		var curstate, num;
		curstate = ds_map_find_first(map[?"states"]);
		num = 0
		while (!is_undefined(curstate))
		{
			if (dev_mode_debug_names && !text_exists("blockstate" + curstate))
				log("block/state/" + curstate + dev_mode_name_translation_message)
				
			with (new(obj_block_state))
			{
				name = curstate
				
				// Parse values (maps or strings)
				var valuelist = ds_map_find_value(map[?"states"], curstate);
				value_amount = ds_list_size(valuelist)
				value_map = ds_map_create()
				
				// Used for the state ID
				id.num = num++
				value_id = other.state_id_amount
				other.state_id_amount *= value_amount
				
				for (var v = 0; v < value_amount; v++)
				{
					var curvalue = valuelist[|v];
					value_name[v] = curvalue
					value_filename[v] = ""
					value_file[v] = null
					value_brightness[v] = null
					
					if (ds_map_valid(curvalue))
					{
						// Name
						value_name[v] = curvalue[?"value"]
						
						// File
						if (is_string(curvalue[?"file"]))
							value_filename[v] = curvalue[?"file"]
							
						// Brightness
						if (is_real(curvalue[?"brightness"]))
							value_brightness[v] = curvalue[?"brightness"]
					}
					
					value_map[?value_name[v]] = v
					
					if (dev_mode_debug_names && string_length(value_name[v]) > 3 && !text_exists("blockstatevalue" + value_name[v]))
						log("block/state/value/" + value_name[v] + dev_mode_name_translation_message)
				}
				
				other.states_map[?curstate] = id
				curstate = ds_map_find_next(map[?"states"], curstate)
			}
		}
	}
	
	// Load default file
	if (filename != "")
		file = block_load_state_file(load_assets_dir + mc_blockstates_directory + filename, id, array())
	else
		file = null
	
	// Default state
	if (is_string(map[?"default_state"]))
		default_state = string_get_state_vars(map[?"default_state"])
	else
		default_state = array()
	
	default_state_id = block_get_state_id(id, default_state)
	
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
		
	// Legacy ID
	legacy_id = value_get_real(map[?"legacy_id"], 0)
	
	// Legacy data
	for (var d = 0; d < 16; d++)
		legacy_data_state[d] = array()
		
	// Read data list into maps
	if (ds_map_valid(map[?"legacy_data"]))
		block_load_legacy_data_map(map[?"legacy_data"], 0, 1)
		
	// Legacy data state ids
	for (var d = 0; d < 16; d++)
		legacy_data_state_id[d] = block_get_state_id(id, legacy_data_state[d])
		
	// Pre-calculate the block variant to pick for each (numerical) state ID
	state_id_model_obj = null
	state_id_brightness = null
	for (var sid = 0; sid < state_id_amount; sid++)
	{
		// Get active file and properties
		var curfile, curbrightness;
		curfile = file
		curbrightness = brightness
		
		// Check states
		if (states_map != null)
		{
			var curstate = ds_map_find_first(states_map);
			while (!is_undefined(curstate))
			{
				with (states_map[?curstate])
				{
					// Find chosen value from current state ID
					var valid = (sid div value_id) mod value_amount;
					
					// Get the properties of the chosen value
					if (value_filename[valid] != "")
					{
						if (value_file[valid] = null)
							value_file[valid] = block_load_state_file(load_assets_dir + mc_blockstates_directory + value_filename[valid], other.id, array(name, value_name[valid]))
						curfile = value_file[valid]
					}
					
					if (value_brightness[valid] != null)
						curbrightness = value_brightness[valid]
				}
				
				curstate = ds_map_find_next(states_map, curstate)
			}
		}
		
		state_id_model_obj[sid] = null
		
		// Open selected file and look for variant or array of multipart cases
		with (curfile)
		{
			var variant = state_id_map[?sid];
			if (is_undefined(variant))
				variant = state_id_map[?0] // Only "normal" is available
				
			other.state_id_model_obj[sid] = variant
			other.state_id_brightness[sid] = curbrightness
		}
	}
	
	return id
}