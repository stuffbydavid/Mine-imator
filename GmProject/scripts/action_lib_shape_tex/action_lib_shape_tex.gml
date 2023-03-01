/// action_lib_shape_tex(resource)
/// @arg resource

function action_lib_shape_tex(res)
{
	var fn;
	fn = ""

	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		if (res = e_option.BROWSE)
		{
			fn = file_dialog_open_image()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.TEXTURE)
			with (res)
				res_load()
		}
		
		history_set_res(action_lib_shape_tex, fn, temp_edit.shape_tex, res)
	}
	
	with (temp_edit)
	{
		if (shape_tex != null && shape_tex.type != e_tl_type.CAMERA)
			shape_tex.count--
		
		shape_tex = res
		
		if (shape_tex != null && shape_tex.type != e_tl_type.CAMERA)
			shape_tex.count++
	}
	
	lib_preview.update = true
}
