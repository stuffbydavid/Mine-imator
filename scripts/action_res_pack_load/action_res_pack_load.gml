/// action_res_pack_load(filename)
/// @arg filename

if (history_undo)
{
	with (history_data)
		history_destroy_loaded()
}
else
{
	var fn, res;
	if (history_redo)
	{
		fn = history_data.filename
		res = new_res(fn, e_res_type.PACK)
	}
	else
	{
		fn = argument0
		res = new_res(fn, e_res_type.PACK_UNZIPPED)
	}
	
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
	}
}

project_reset_loaded()
