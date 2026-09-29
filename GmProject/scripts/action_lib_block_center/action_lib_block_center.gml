function action_lib_block_center(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_block_center, temp_edit.block_center, enabled, false)

	with (temp_edit)
	{
		block_center = enabled
		temp_update_rot_point()
	}

	tl_update_matrix()
	
	lib_preview.update = true
}
