/// action_lib_block_name(name)
/// @arg name
/// @desc Sets the block name of the selected library template.

var name, state;

if (history_undo)
{
	name = history_data.old_value
	state = array_copy_1d(history_data.state)
}
else if (history_redo)
{
	name = history_data.new_value
	state = array_copy_1d(history_data.state)
}
else
{
	name = argument0
	with (history_set_var(action_lib_block_name, temp_edit.block_name, name, false))
		id.state = array_copy_1d(temp_edit.block_state)
	state = array_copy_1d(mc_assets.block_name_map[?name].default_state)
}

with (temp_edit)
{
	block_name = name
	block_state = state
	temp_update_block()
	temp_update_display_name()
}

lib_preview.update = true
