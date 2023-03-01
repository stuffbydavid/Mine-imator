/// action_res_font_load(filename)
/// @arg filename

function action_res_font_load(fn)
{
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var hobj, res;
		
		if (history_redo)
			fn = history_data.filename
		else
			hobj = history_set(action_res_font_load)
		
		res = new_res(fn, e_res_type.FONT)
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
}
