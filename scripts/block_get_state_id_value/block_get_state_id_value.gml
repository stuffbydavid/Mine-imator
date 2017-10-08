/// block_get_state_id(block, stateid, name)
/// @arg block
/// @arg stateid
/// @arg name
/// @desc Extracts a value from the state ID.

var block, stateid, name, state;
block = argument0
stateid = argument1
name = argument2
state = block.states_map[?name]

return state.value_name[(stateid div state.value_id) mod state.value_amount]
