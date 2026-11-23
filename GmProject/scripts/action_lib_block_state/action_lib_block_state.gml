function action_lib_block_state(value)
{
	var state;

	if (!history_undo && !history_redo)
	{
		if (is_undefined(menu_block_state) || menu_block_state = null)
			return null
		
		state = menu_block_state.name
		
		with (history_set_var(action_lib_block_state, state_vars_get_value(obj_edit.block_state, state), value, false))
			self.state = state
	}
	else
		state = history_data.state
	
	with (obj_edit)
	{
		state_vars_set_value(block_state, state, value)
		
		asset_picker_state_map[?mc_assets.block_name_map[?block_name]] = array_copy_1d(block_state)
		asset_picker_set_state(state, value)
		
		temp_update_block()
		temp_update_display_name()
	}
	
	lib_preview.update = true
}
