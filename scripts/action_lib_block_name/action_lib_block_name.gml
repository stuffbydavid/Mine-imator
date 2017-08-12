/// action_lib_block_name(block)
/// @arg block
/// @desc Sets the block name of the selected library template.

var block;

if (history_undo)
	block = history_data.oldval
else if (history_redo)
	block = history_data.newval
else
{
	block = argument0
	history_set_var(action_lib_block_name, temp_edit.block_name, block, false)
}

with (temp_edit)
{
	block_name = block
	temp_update_block_state()
	temp_update_block()
	temp_update_display_name()
}

lib_preview.update = true
