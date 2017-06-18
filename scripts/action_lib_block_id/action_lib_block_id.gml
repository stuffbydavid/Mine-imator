/// action_lib_block_id(block)
/// @arg block
/// @desc Sets the block id of the selected library item.

var block;

if (history_undo)
	block = history_data.oldval
else if (history_redo)
	block = history_data.newval
else
{
	block = argument0
	history_set_var(action_lib_block_id, temp_edit.block_id, block, false)
}

with (temp_edit)
{
	block_id = block
	temp_update_block()
	temp_update_display_name()
}

lib_preview.update = true
