function action_lib_item_3d(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_3d, temp_edit.item_3d, enabled, false)
	
	with (temp_edit)
	{
		item_3d = enabled
		
		render_generate_item()
		temp_update_rot_point()
	}
	
	tl_update_matrix()
	
	lib_preview.update = true
}
