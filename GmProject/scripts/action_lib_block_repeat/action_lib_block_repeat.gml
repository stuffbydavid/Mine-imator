/// action_lib_block_repeat(value, add)
/// @arg value
/// @arg add

function action_lib_block_repeat(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_block_repeat, temp_edit.block_repeat[axis_edit], temp_edit.block_repeat[axis_edit] * add + val, true)
	
	with (temp_edit)
	{
		block_repeat[axis_edit] = block_repeat[axis_edit] * add + val
		temp_update_block()
		temp_update_rot_point()
	}
	
	tl_update_matrix()
	lib_preview.update = true
}
