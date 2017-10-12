/// block_get_state_id_state_vars(block, stateid)
/// @arg block
/// @arg stateid

var block, stateid, vars;
block = argument0
stateid = argument1
vars = array()

var key, i;
key = ds_map_find_first(block.states_map)
i = 0
while (!is_undefined(key))
{
	vars[i * 2] = block.states_map[?key].name
	vars[i * 2 + 1] = block_get_state_id_value(block, stateid, block.states_map[?key].name)
	key = ds_map_find_next(block.states_map, key)
	i++
}

return vars