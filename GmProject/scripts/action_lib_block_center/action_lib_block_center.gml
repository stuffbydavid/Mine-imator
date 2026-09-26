/// action_lib_block_center(center)
/// @arg center

function action_lib_block_center(center)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_block_center, temp_edit.block_center, center, false)

	with (temp_edit)
	{
		block_center = center
		temp_update_rot_point()
	}

	tl_update_matrix()
	lib_preview.update = true
}