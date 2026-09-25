/// action_tl_text_3d(is3d)
/// @arg is3d

function action_tl_text_3d(is3d)
{
	if (!history_undo && !history_redo)
		history_set_var(action_tl_text_3d, tl_edit.text_3d, is3d, false)

	with (tl_edit)
	{
		text_3d = is3d
		temp_update_rot_point()
	}

	tl_update_matrix()
}
