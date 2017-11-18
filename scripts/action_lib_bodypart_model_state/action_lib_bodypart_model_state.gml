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
	with (history_set_var(action_lib_bodypart_model_state, state_vars_get_value(temp_edit.model_state, state), val, false))
		id.state = state
}

with (temp_edit)
{
	if (state_vars_get_value(model_state, state) = val) 
		return 0
		
	state_vars_set_value(model_state, state, val)
	temp_update_model()
	temp_update_model_part()
	temp_update_model_plane_vbuffer_map()
	temp_update_display_name()
}

lib_preview.update = true
tl_update_matrix()