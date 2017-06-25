/// action_background_ground_tex(resource)
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
		fn = file_dialog_open_image_pack()
		if (!file_exists_lib(fn))
			return 0
		
		res = new_res(fn, "blocksheet")
		with (res)
			res_load()
	}
	history_set_res(action_background_ground_tex, fn, background_ground_tex, res)
}

background_ground_tex.count--
background_ground_tex = res
background_ground_tex.count++
background_ground_update_texture()
