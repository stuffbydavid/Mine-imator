/// action_lib_block_name(name)
/// @arg name
/// @desc Sets the block name of the selected library template.

var name, state;

if (history_undo)
{
	name = history_data.old_value
	state = history_data.state
}
else if (history_redo)
{
	name = history_data.new_value
	state = history_data.state
}
else
{
	name = argument0
	with (history_set_var(action_lib_block_name, temp_edit.block_name, name, false))
		id.state = temp_edit.block_state
	state = mc_version.block_name_map[?name].default_state
}

with (temp_edit)
{
	block_name = name
	block_state = state
	temp_update_block_state_map()
	temp_update_block()
	temp_update_display_name()
}

lib_preview.update = true
