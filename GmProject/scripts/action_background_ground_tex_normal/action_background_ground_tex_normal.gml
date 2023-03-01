/// action_background_ground_tex_normal(resource)
/// @arg resource

function action_background_ground_tex_normal(res)
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
			fn = file_dialog_open_image_pack()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.BLOCK_SHEET)
			with (res)
				res_load()
		}
		
		history_set_res(action_background_ground_tex_normal, fn, background_ground_tex_normal, res)
	}
	
	background_ground_tex_normal.count--
	background_ground_tex_normal = res
	background_ground_tex_normal.count++
	background_ground_update_texture_normal()
}
