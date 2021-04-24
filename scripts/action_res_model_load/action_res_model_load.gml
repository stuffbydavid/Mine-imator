/// action_res_model_load(filename)
/// @arg filename

function action_res_model_load(fn)
{

	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var hobj, res, temp;
		
		if (history_redo)
			fn = history_data.filename
		else
			hobj = history_set(action_res_model_load)
		
		var res = new_res(fn, e_res_type.MODEL);
		res.loaded = !res.replaced
		
		if (res.replaced)
			action_res_replace(fn)
		else
			with (res)
				res_load()
		
		temp = new_obj(obj_template)
		with (temp)
		{
			loaded = true
			type = e_temp_type.MODEL
			model_tex = null
			model = res
			model.count++
			temp_update()
			with (temp_animate())
			{
				loaded = true
				for (var p = 0; p < ds_list_size(part_list); p++)
					part_list[|p].loaded = true
			}
			sortlist_add(other.lib_list, id)
		}
		
		if (!history_redo)
		{
			with (hobj)
			{
				filename = fn
				history_save_loaded()
			}
		}
	}
	
	project_reset_loaded()
	
	tl_update_length()
	tl_update_list()
	tl_update_matrix()
}
