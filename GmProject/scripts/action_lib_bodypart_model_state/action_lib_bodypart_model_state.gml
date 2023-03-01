/// action_lib_bodypart_model_state(value)
/// @arg value
function action_lib_bodypart_model_state(val)
{
	var state;
	
	if (!history_undo && !history_redo)
	{
		state = menu_model_state.name
		
		with (history_set_var(action_lib_bodypart_model_state, state_vars_get_value(temp_edit.model_state, state), val, false))
			id.state = state
	}
	else
		state = history_data.state
	
	with (temp_edit)
	{
		if (state_vars_get_value(model_state, state) = val) 
			return 0
		
		state_vars_set_value(model_state, state, val)
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		temp_update_display_name()
		model_shape_update_color()
	}
	
	lib_preview.update = true
	tl_update_matrix()
}
