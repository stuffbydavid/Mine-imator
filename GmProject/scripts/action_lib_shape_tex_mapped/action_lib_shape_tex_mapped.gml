/// action_lib_shape_tex_mapped(map)
/// @arg map

function action_lib_shape_tex_mapped(map)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_mapped, temp_edit.shape_tex_mapped, map, false)
	
	with (temp_edit)
	{
		shape_tex_mapped = map
		temp_update_shape()
	}
	
	lib_preview.update = true
}
