/// action_res_image_load(type, filename)
/// @arg type
/// @arg filename

if (history_undo)
{
	with (history_data)
		history_destroy_loaded()
}
else
{
	var type, fn, hobj, res;
	
	if (history_redo)
	{
		type = history_data.type
		fn = history_data.fn
	}
	else
	{
		type = argument0
		fn = argument1
		hobj = history_set(action_res_image_load)
	}
	
	res = new_res(type, fn)
	res.loaded = true
	with (res)
		res_load()
	
	if (!history_redo && !res.replaced)
	{
		with (hobj)
		{
			id.type = type
			id.fn = fn
			history_save_loaded()
		}
	}
}

project_reset_loaded()
