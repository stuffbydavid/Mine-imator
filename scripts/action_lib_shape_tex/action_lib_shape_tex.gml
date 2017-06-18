/// action_lib_shape_tex(resource)
/// @arg resource

var res, fn;
fn = ""

if (history_undo)
	res = history_undo_res()
else if (history_redo)
	res = history_redo_res()
else
{
	res = argument0
	if (res = e_option.BROWSE)
	{
		fn = file_dialog_open_image()
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res("texture", fn)
		with (res)
			res_load()
	}
	history_set_res(action_lib_shape_tex, fn, temp_edit.shape_tex, res)
}

with (temp_edit)
{
	if (shape_tex && shape_tex.type != "camera")
		shape_tex.count--
	shape_tex = res
	if (shape_tex && shape_tex.type != "camera")
		shape_tex.count++
}

lib_preview.update = true
