/// action_lib_bodypart_model_name(name)
/// @arg name
/// @desc Changes the character body part model.

function action_lib_bodypart_model_name(name)
{
	var state;
	
	if (!history_undo && !history_redo)
	{
		with (history_set_var(action_lib_bodypart_model_name, temp_edit.model_name, name, false))
			id.state = array_copy_1d(temp_edit.model_state)
		
		state = mc_assets.model_name_map[?name].default_state
	}
	else
		state = history_data.state
	
	with (temp_edit)
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
