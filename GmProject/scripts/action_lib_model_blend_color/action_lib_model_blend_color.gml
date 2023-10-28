/// action_lib_model_blend_color(col)
/// @arg col

function action_lib_model_blend_color(col)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_model_blend_color, temp_edit.model_blend_color, col, true)
	
	with (temp_edit)
		id.model_blend_color = col
}
