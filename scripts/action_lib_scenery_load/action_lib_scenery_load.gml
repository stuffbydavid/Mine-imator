/// action_lib_scenery_load(filename)
/// @arg filename

if (history_undo)
{
	with (history_data)
		history_destroy_loaded()
}
else
{
	var fn, hobj, res, temp, tl;
	
	if (history_redo)
		fn = history_data.fn
	else
	{
		fn = argument0
		hobj = history_set(action_lib_scenery_load)
	}
	
	res = new_res(fn, "schematic")
	res.loaded = !res.replaced
	with (res)
		res_load()
		
	with (new(obj_template))
	{
		sortlist_add(app.lib_list, id)
		loaded = true
		type = "scenery"
		scenery = res
		scenery.count++
		block_tex = res_def
		res_def.count++
		temp_update_display_name()
		tl = temp_animate()
		tl.loaded = true
	}
	
	if (!history_redo)
	{
		with (hobj)
		{
			id.fn = fn
			history_save_loaded()
		}
	}
}

project_reset_loaded()
tl_update_list()
tl_update_matrix()
