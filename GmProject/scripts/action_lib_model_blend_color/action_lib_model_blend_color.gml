function action_lib_model_blend_color(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_model_blend_color, temp_edit.model_blend_color, color, true)
	
	with (temp_edit)
		self.model_blend_color = color
}
