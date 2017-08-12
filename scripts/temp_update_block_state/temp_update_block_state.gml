/// temp_update_block_state()
/// @desc Resets the state to the default.

var block = mc_version.block_name_map[?block_name]

if (is_undefined(block))
	return 0

block_state = block.default_state
if (block_state_map = null)
	block_state_map = ds_map_create()

ds_map_clear(block_state_map)

if (block.default_state != "")
	ds_map_merge(block_state_map, block.default_state_map)