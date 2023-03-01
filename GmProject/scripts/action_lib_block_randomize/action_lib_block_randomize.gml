/// action_lib_block_randomize(enable)
/// @arg enable

function action_lib_block_randomize(rep)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_block_randomize, temp_edit.block_randomize, rep, false)
	
	with (temp_edit)
	{
		block_randomize = rep
		temp_update_block()
		temp_update_rot_point()
	}
	
	tl_update_matrix()
	lib_preview.update = true
}
