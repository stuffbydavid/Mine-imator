function action_bench_model_state(value)
{
	var state, settings;
	state = menu_model_state.name
	settings = place_build ? build_settings : bench_settings
	
	with (settings)
	{
		if (app.menu_model_armor_variant)
		{
			if (value = "multiple")
				return 0
			
			for (var i = 0; i < array_length(armor_parts); i++)
				state_vars_set_value(model_state, armor_parts[i], value)
			
			app.menu_model_armor_variant = false
		}
		else
		{
			if (state_vars_get_value(model_state, state) = value)
				return 0
			
			state_vars_set_value(model_state, state, value)
		}
		
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		
		model_shape_update_color()
		
		if (preview != null)
			with (preview)
				update = true
	}
}
