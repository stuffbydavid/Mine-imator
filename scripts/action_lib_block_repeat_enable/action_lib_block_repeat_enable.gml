/// action_lib_block_repeat_enable(enable)
/// @arg enable

function action_lib_block_repeat_enable(rep)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_block_repeat_enable, temp_edit.block_repeat_enable, rep, false)
	
	with (temp_edit)
	{
		block_repeat_enable = rep
		temp_update_block()
		temp_update_rot_point()
	}
	
	lib_preview.update = true
}
