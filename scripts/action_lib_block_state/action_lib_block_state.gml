/// action_lib_block_state(value)
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
	state = menu_block_state.name
	with (history_set_var(action_lib_block_state, state_vars_get_value(temp_edit.block_state, state), val, false))
		id.state = state
}

with (temp_edit)
{
	state_vars_set_value(block_state, state, val)
	temp_update_block()
	temp_update_display_name()
}

lib_preview.update = true
