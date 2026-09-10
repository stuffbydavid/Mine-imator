/// action_bench_model_state(value)
/// @arg value

function action_bench_model_state(val)
{
	var state = menu_model_state.name;
	
	with (bench_settings)
	{
		if (app.menu_model_armor_variant)
		{
			if (val = "multiple")
				return 0
			for (var i = 0; i < array_length(armor_parts); i++)
				state_vars_set_value(model_state, armor_parts[i], val)
			app.menu_model_armor_variant = false
		}
		else
		{
			if (state_vars_get_value(model_state, state) = val)
				return 0
			state_vars_set_value(model_state, state, val)
		}
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		model_shape_update_color()
		
		with (preview)
			update = true
	}
}
