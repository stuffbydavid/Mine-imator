/// action_lib_item_3d(is3d)
/// @arg is3d

function action_lib_item_3d(is3d)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_3d, temp_edit.item_3d, is3d, false)
	
	with (temp_edit)
	{
		item_3d = is3d
		render_generate_item()
		temp_update_rot_point()
	}
	
	lib_preview.update = true
}
