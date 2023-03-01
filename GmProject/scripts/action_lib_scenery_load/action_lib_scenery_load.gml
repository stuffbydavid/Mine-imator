/// action_lib_scenery_load(filename)
/// @arg filename

function action_lib_scenery_load(fn)
{
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()
	}
	else
	{
		var hobj = null;
		
		if (history_redo)
			fn = history_data.filename
		else
			hobj = history_set(action_lib_scenery_load)
		
		var res = new_res(fn, e_res_type.SCENERY);
		res.loaded = !res.replaced
		if (res.replaced)
		{
			res_edit = res 
			action_res_replace(fn)
		}
		else
			with (res)
				res_load()
		
		with (new_obj(obj_template))
		{
			type = e_temp_type.SCENERY
			scenery = res
			scenery.count++
			
			block_tex = mc_res
			block_tex_material = mc_res
			block_tex_normal = mc_res
			mc_res.count += 3
			
			temp_update_display_name()
			loaded = true
			with (temp_animate())
				loaded = true
			sortlist_add(app.lib_list, id)
		}
		
		with (hobj)
		{
			filename = fn
			history_save_loaded()
		}
	}
	
	project_reset_loaded()
	
	tl_update_list()
	tl_update_matrix()
}
