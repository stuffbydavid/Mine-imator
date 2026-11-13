function action_bench_model_state(value)
{
	var states, settings;
	settings = place_build ? build_settings : bench_settings
	states = model_set_state(settings.model_state, menu_model_state.name, value)
	if (states = null)
		return 0

	for (var i = 0; i < array_length(states); i += 2)
		if (state_vars_get_value(settings.model_state, states[i]) != states[i + 1])
			asset_picker_set_state(states[i], states[i + 1])

	asset_picker_state_map[?mc_assets.model_name_map[?settings.model_name]] = array_copy_1d(states)
	
	with (settings)
	{
		model_state = array_copy_1d(states)
		
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		
		model_shape_update_color()
		
		if (preview != null)
			with (preview)
				update = true
	}
}
