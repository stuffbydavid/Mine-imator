/// @desc Cycles the first available picker state, or the first editable state.
/// @arg direction

function action_build_state_scroll(direction)
{
	var asset, states, special, state;
	special = (build_settings.type = e_temp_type.SPECIAL_BLOCK)
	if (special)
	{
		asset = mc_assets.model_name_map[?build_settings.model_name]
		states = build_settings.model_state
	}
	else
	{
		asset = mc_assets.block_name_map[?build_settings.block_name]
		states = build_settings.block_state
	}

	if (asset.states_map = null)
		return 0

	// Prefer the configured picker states
	state = null
	for (var i = 0; i < ds_list_size(mc_assets.state_picker_list); i++)
	{
		var name = mc_assets.state_picker_list[|i];
		if (ds_map_exists(asset.states_map, name) && asset.states_map[?name].value_amount > 1)
		{
			state = asset.states_map[?name]
			break
		}
	}

	// Fall back to the first state with multiple values
	if (state = null)
	{
		for (var i = 0; i < array_length(asset.default_state); i += 2)
		{
			var name = asset.default_state[i];
			if (ds_map_exists(asset.states_map, name) && asset.states_map[?name].value_amount > 1)
			{
				state = asset.states_map[?name]
				break
			}
		}
	}
	
	if (state = null)
		return 0

	// Apply the value through the same actions as the state controls
	var value, index, prevstate, prevarmor;
	value = state_vars_get_value(states, state.name)
	index = 0
	for (var i = 0; i < state.value_amount; i++)
		if (state.value_name[i] = value)
			index = i
	
	value = state.value_name[mod_fix(index + direction, state.value_amount)]

	if (special)
	{
		prevstate = menu_model_state
		prevarmor = menu_model_armor_variant
		menu_model_state = state
		menu_model_armor_variant = false
		
		action_bench_model_state(value)
		
		menu_model_state = prevstate
		menu_model_armor_variant = prevarmor
	}
	else
	{
		prevstate = menu_block_state
		menu_block_state = state
		
		action_bench_block_state(value)
		
		menu_block_state = prevstate
	}
}
