/// action_lib_bodypart_model_state(value)
/// @arg value

var val, state;

if (history_undo)
{
	val = history_data.old_value
	state = history_data.state
}
else if (history_redo)
{
	val = history_data.new_value
	state = history_data.state
}
else
{
	val = argument0
	state = menu_model_state.name
	with (history_set_var(action_lib_bodypart_model_state, temp_edit.model_state_map[?state], val, false))
		id.state = state
}

with (temp_edit)
{
	if (model_state_map[?state] = val) 
		return 0
		
	model_state_map[?state] = val
	model_state = state_vars_map_to_string(model_state_map)
	temp_update_model()
	temp_update_model_part()
	temp_update_display_name()
}

lib_preview.update = true
tl_update_matrix()