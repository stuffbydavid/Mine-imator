/// action_res_model_load(filename)
/// @arg filename

if (history_undo)
{
	with (history_data)
		history_destroy_loaded()
}
else
{
	var fn, hobj, res;
	
	if (history_redo)
		fn = history_data.filename
	else
	{
		fn = argument0
		hobj = history_set(action_res_model_load)
	}
	
	res = new_res(fn, e_res_type.MODEL)
	with (res)
	{
		loaded = true
		res_load()
	}
	
	if (!history_redo && !res.replaced)
	{
		with (hobj)
		{
			filename = fn
			history_save_loaded()
		}
	}
}

project_reset_loaded()