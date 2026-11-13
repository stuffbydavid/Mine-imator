/// @desc Sets the block name of the selected library template.
/// @arg name
/// @arg [state]

function action_lib_block_name(name, state = null)
{
	if (!history_undo && !history_redo)
	{
		if (state = null)
			state = array_copy_1d(mc_assets.block_name_map[?name].default_state)
		
		if (obj_edit.block_name = name && array_equals(obj_edit.block_state, state))
			return 0

		asset_picker_state_map[?mc_assets.block_name_map[?name]] = array_copy_1d(state)
		
		with (history_set_var(action_lib_block_name, obj_edit.block_name, name, false))
		{
			old_state = array_copy_1d(obj_edit.block_state)
			new_state = array_copy_1d(state)
		}
	}
	else
		state = array_copy_1d(history_undo ? history_data.old_state : history_data.new_state)
	
	with (obj_edit)
	{
		block_name = name
		block_state = state
		
		temp_update_block()
		temp_update_display_name()
	}

	lib_preview.update = true
}
