/// action_lib_block_state(value)
/// @arg value

var val, state;

if (history_undo)
{
	val = history_data.oldval
	state = history_data.state
}
else if (history_redo)
{
	val = history_data.newval
	state = history_data.state
}
else
{
	val = argument0
	state = menu_block_state.name
	with (history_set_var(action_lib_block_state, temp_edit.block_state_map[?state], val, false))
		id.state = state
}

with (temp_edit)
{
	if (block_state_map[?state] = val) 
		return 0
		
	block_state_map[?state] = val
	block_state = block_vars_map_to_string(block_state_map)
	temp_update_block()
}

lib_preview.update = true
