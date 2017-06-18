/// block_load(map)
/// @arg map

var map = argument0;

with (new(obj_block))
{
	var name, type, defaultname, states;
	name = ""
	type = ""
	defaultname = ""
	states = ""
	vars = null
	
	if (is_string(map[?"name"]))
		name = map[?"name"]
		
	if (is_string(map[?"type"]))
		type = map[?"type"]
		
	if (is_string(map[?"defaultname"]))
		defaultname = map[?"defaultname"]
	
	if (is_string(map[?"states"]))
		states = map[?"states"]
	
	if (is_string(map[?"set"]))
	{
		vars = ds_map_create()
		block_load_vars(vars, map[?"set"])
	}
	
	// Set data fields
	for (var d = 0; d < 16; d++)
	{
		data_name[d] = name
		data_type[d] = type
		data_default_name[d] = defaultname
		data_states[d] = states
		data_vars[d] = vars
	}
		
	// Read data list
	if (is_real(map[?"data"]) && ds_exists(map[?"data"], ds_type_map))
		block_load_data_map(map[?"data"], 0, 1)
		
	// Load states
	for (var d = 0; d < 16; d++)
	{
		if (data_states[d] != "")
		{
			data_states[d] = block_load_states(data_states[d], data_type[d])
			if (!data_states[d])
				return null
		}
		else
			data_states[d] = null
	}
	
	return id
}