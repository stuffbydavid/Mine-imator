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
		fn = history_data.fn 
		res = new_res(fn, "pack")
	}
	else
	{
		fn = argument0
		res = new_res(fn, "packunzipped")
	}
	
	res.loaded = true
	with (res)
		res_load()
		
	if (!history_redo && !res.replaced)
	{
		with (history_set(action_res_pack_load))
		{
			id.fn = fn
			save_iid_current--
			history_save_loaded()
		}
	}
}

project_reset_loaded()
