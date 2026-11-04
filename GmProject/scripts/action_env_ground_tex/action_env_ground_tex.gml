/// @arg resource

function action_env_ground_tex(res)
{
	if (history_undo)
		res = history_undo_res()
	else if (history_redo)
		res = history_redo_res()
	else
	{
		var fn = "";
		
		if (res = e_option.BROWSE)
		{
			fn = file_dialog_open_image_pack()
			if (!file_exists_lib(fn))
				return 0
			
			res = new_res(fn, e_res_type.BLOCK_SHEET)
			with (res)
				res_load()
		}
		
		history_set_res(action_env_ground_tex, fn, env_ground_tex, res)
	}
	
	env_ground_tex = res
	
	env_ground_update_texture()
	project_update_counts()
}
