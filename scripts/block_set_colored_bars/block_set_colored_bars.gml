/// block_set_colored_bars()
/// @desc Runs the script for bars, but retains the color attribute of the block.

var color = block_get_state_id_value(block_current, block_state_id_current, "color");
block_set_bars()
block_state_id_current = block_set_state_id_value(block_current, block_state_id_current, "color", color)

return 0