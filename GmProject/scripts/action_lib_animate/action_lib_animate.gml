/// action_lib_animate()

function action_lib_animate()
{
	if (history_undo)
	{
		with (save_id_find(history_data.tl_save_id))
			tl_remove_clean()
		
		with (obj_timeline)
			if (delete_ready)
				instance_destroy()

		if (history_data.scenery_replace_ground)
			background_ground_show = history_data.scenery_ground_show
	}
	else
	{
		var hobj, tl, sceneryreplaceground;
		hobj = null
		sceneryreplaceground = false
		
		if (history_redo)
			sceneryreplaceground = history_data.scenery_replace_ground
		else
		{
			hobj = history_set(action_lib_animate)
			if (temp_edit.type = e_temp_type.SCENERY && temp_edit.scenery != null && setting_scenery_replace_ground &&
				temp_edit.scenery.scenery_size[X] > scenery_large_threshold && temp_edit.scenery.scenery_size[Y] > scenery_large_threshold)
			{
				sceneryreplaceground = true
				hobj.scenery_replace_ground = true
				hobj.scenery_ground_show = background_ground_show
			}
		}
		
		with (temp_edit)
			tl = temp_animate()
		
		if (sceneryreplaceground)
			with (tl)
				tl_replace_ground()

		with (hobj)
			tl_save_id = save_id_get(tl)
	}
	
	tl_update_list()
	tl_update_matrix()
}
