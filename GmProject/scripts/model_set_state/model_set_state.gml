/// @desc Returns changed model states, or null if unchanged.
/// @arg states
/// @arg state
/// @arg value

function model_set_state(states, state, value)
{
	var result = array_copy_1d(states);

	// Change all armor variants together, preserving mixed values in the original
	if (app.menu_model_armor_variant)
	{
		app.menu_model_armor_variant = false
		
		if (value = "multiple")
			return null

		for (var i = 0; i < array_length(armor_parts); i++)
			state_vars_set_value(result, armor_parts[i], value)
	}
	else
		state_vars_set_value(result, state, value)

	if (array_equals(states, result))
		return null

	return result
}
