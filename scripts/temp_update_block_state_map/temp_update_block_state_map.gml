/// temp_update_block_state_map()
/// @desc Updates the block state map.

var block = mc_version.block_name_map[?block_name]

if (is_undefined(block))
	return 0

if (block_state_map = null)
	block_state_map = ds_map_create()

ds_map_clear(block_state_map)

if (block_state != "")
	state_vars_string_to_map(block_state, block_state_map)