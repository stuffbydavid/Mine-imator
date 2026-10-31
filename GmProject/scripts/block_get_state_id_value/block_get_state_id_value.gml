/// @desc Extracts a value from the state ID.

function block_get_state_id_value(block, stateid, name)
{
	if (block = null || block.states_map = null)
		return undefined
	
	var state = block.states_map[?name];
	if (is_undefined(state))
		return undefined
	
	return state.value_name[(stateid div state.value_id) mod state.value_amount]
}
