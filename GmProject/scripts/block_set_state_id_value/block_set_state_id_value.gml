/// @desc Sets a value in the given state, returns the new state ID.
/// @arg block
/// @arg stateid
/// @arg name
/// @arg value

function block_set_state_id_value(block, stateid, name, val)
{
	if (block = null || block.states_map = null)
		return stateid
	
	var state = block.states_map[?name];
	if (is_undefined(state))
		return stateid
	
	stateid -= ((stateid div state.value_id) mod state.value_amount) * state.value_id // Remove old
	stateid += state.value_map[?val] * state.value_id // Add new
	
	return stateid
}
