/// action_res_scenery_animate(resource)
/// Creates a new template of the given scenery resource and animates it.
function action_res_scenery_animate(res)
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
			res = save_id_find(history_data.res)
		else
			hobj = history_set(action_res_scenery_animate)
	
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
			self.res = save_id_get(res)
			history_save_loaded()
		}
	}

	project_reset_loaded()
	tl_update_list()
	tl_update_matrix()

}