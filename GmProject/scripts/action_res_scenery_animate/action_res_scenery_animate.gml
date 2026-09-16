/// action_res_scenery_animate(resource)
/// Creates a new template of the given scenery resource and animates it.
function action_res_scenery_animate(res)
{
	if (history_undo)
	{
		with (history_data)
			history_destroy_loaded()

		if (history_data.scenery_replace_ground)
			background_ground_show = history_data.scenery_ground_show
	}
	else
	{
		var hobj, sceneryreplaceground;
		hobj = null
		sceneryreplaceground = false
	
		if (history_redo)
		{
			res = save_id_find(history_data.res)
			sceneryreplaceground = history_data.scenery_replace_ground
		}
		else
		{
			hobj = history_set(action_res_scenery_animate)
			
			if (res.type = e_res_type.FROM_WORLD && setting_scenery_replace_ground &&
				res.scenery_size[X] > scenery_large_threshold && res.scenery_size[Y] > scenery_large_threshold)
			{
				sceneryreplaceground = true
				hobj.scenery_replace_ground = true
				hobj.scenery_ground_show = background_ground_show
			}
		}
	
		with (new_obj(obj_template))
		{
			type = e_temp_type.SCENERY
			scenery = res
			
			block_tex = project_pack_res
			block_tex_material = project_pack_res
			block_tex_normal = project_pack_res
			
			temp_update_display_name()
			loaded = true
			with (temp_animate())
			{
				loaded = true
				if (sceneryreplaceground)
					tl_replace_ground()
			}
			sortlist_add(app.lib_list, id)
		}

		if (sceneryreplaceground)
			background_ground_show = false
	
		with (hobj)
		{
			self.res = save_id_get(res)
			history_save_loaded()
		}
	}

	project_reset_loaded()
	tl_update_list()
	tl_update_matrix()
	project_update_counts()

}
