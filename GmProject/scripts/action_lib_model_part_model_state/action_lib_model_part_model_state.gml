function action_lib_model_part_model_state(value)
{
	var states;
	
	if (!history_undo && !history_redo)
	{
		states = model_set_state(obj_edit.model_state, menu_model_state.name, value)
		if (states = null)
			return 0

		history_set_var(action_lib_model_part_model_state, array_copy_1d(obj_edit.model_state), states, false)
		value = states
	}
	
	for (var i = 0; i < array_length(value); i += 2)
		if (state_vars_get_value(obj_edit.model_state, value[i]) != value[i + 1])
			asset_picker_set_state(value[i], value[i + 1])

	asset_picker_state_map[?mc_assets.model_name_map[?obj_edit.model_name]] = array_copy_1d(value)

	with (obj_edit)
	{
		model_state = array_copy_1d(value)
		
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		temp_update_display_name()
		
		model_shape_update_color()
	}
	
	lib_preview.update = true
	
	tl_update_matrix()
}
