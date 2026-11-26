/// @desc Applies compatible state values and search terms to an asset's default state.
/// @arg asset
/// @arg state
/// @arg [search]

function minecraft_asset_get_state(asset, state, search = "")
{
	var vars, type, searchvalues;
	vars = array_copy_1d(asset.default_state)
	if (asset.states_map = null)
		return vars
	
	type = (asset.object_index = obj_model ? "model" : "block")
	searchvalues = (search != "" && !string_contains(string_lower(minecraft_asset_get_name(type, asset.name)), search))
	
	for (var i = 0; i < array_length(vars); i += 2)
	{
		var name, values, value;
		name = vars[i]
		values = asset.states_map[?name]
		
		if (is_undefined(values))
			continue
		
		value = state_vars_get_value(state, name)
		if (array_contains(values.value_name, value))
			vars[i + 1] = value

		if (!searchvalues)
			continue
		
		for (var v = 0; v < values.value_amount; v++)
		{
			value = values.value_name[v]
			if (string_contains(string_lower(minecraft_asset_get_name(type + "/state/value", value)), search))
			{
				vars[i + 1] = value
				break
			}
		}
	}
	
	return vars
}
