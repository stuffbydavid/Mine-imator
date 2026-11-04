function action_lib_text_3d(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_3d, temp_edit.text_3d, enabled, false)
	
	with (temp_edit)
	{
		text_3d = enabled
		temp_update_rot_point()
	}
	
	tl_update_matrix()
	
	lib_preview.update = true
}
