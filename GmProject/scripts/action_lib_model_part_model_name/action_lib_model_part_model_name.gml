/// @desc Changes the character body part model.
/// @arg name
/// @arg [state]

function action_lib_model_part_model_name(name, state = null)
{
	if (!history_undo && !history_redo)
	{
		if (state = null)
			state = array_copy_1d(mc_assets.model_name_map[?name].default_state)
		
		if (obj_edit.model_name = name && array_equals(obj_edit.model_state, state))
			return 0

		asset_picker_state_map[?mc_assets.model_name_map[?name]] = array_copy_1d(state)
		
		with (history_set_var(action_lib_model_part_model_name, obj_edit.model_name, name, false))
		{
			old_state = array_copy_1d(obj_edit.model_state)
			new_state = array_copy_1d(state)
		}
	}
	else
		state = history_undo ? history_data.old_state : history_data.new_state
	
	with (obj_edit)
	{
		model_name = name
		model_state = array_copy_1d(state)
		
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
		temp_update_display_name()
		
		model_shape_update_color()
	}
	
	lib_preview.update = true
	
	tl_update_matrix()
}
