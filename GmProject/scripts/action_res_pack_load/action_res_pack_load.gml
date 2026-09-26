/// action_res_pack_load(filename, [unpacked, projectpack])
/// @arg filename

function action_res_pack_load(fn, unpacked = true, projectpack = false)
{
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var res;
		if (history_redo)
		{
			fn = history_data.filename
			res = new_res(fn, e_res_type.PACK)
		}
		else if (unpacked)
			res = new_res(fn, e_res_type.PACK_UNZIPPED)
		else
			res = new_res(fn, e_res_type.PACK)
		fn = load_folder + "/" + res.filename
		
		res.loaded = true
		with (res)
			res_load()
		
		if (!history_redo && !res.replaced)
		{
			with (history_set(action_res_pack_load))
			{
				filename = fn
				history_save_loaded()
			}

			if (projectpack || question(text_get("questionprojectpack")))
				action_project_pack(res)
		}
	}
	
	project_reset_loaded()
}
