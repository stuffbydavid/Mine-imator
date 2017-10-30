/// action_res_model_load(filename)
/// @arg filename

if (history_undo)
{
	with (history_data)
		history_destroy_loaded()
}
else
{
	var fn, hobj, res, temp;
	
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
	
	temp = new(obj_template)
	with (temp)
	{
		loaded = true
		type = e_temp_type.MODEL
		model_tex = null
		model = res
		model.count++
		temp_update()
		sortlist_add(other.lib_list, id)
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