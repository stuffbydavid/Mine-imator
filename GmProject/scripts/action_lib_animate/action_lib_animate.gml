/// action_lib_animate([place])

function action_lib_animate(place = false)
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
		var hobj, tl, sceneryreplaceground, par;
		hobj = null
		sceneryreplaceground = false
		
		if (history_redo)
		{
			hobj = history_data
			par = save_id_find(history_data.parent_save_id)
			if (par = null)
				par = app
			sceneryreplaceground = history_data.scenery_replace_ground
		}
		else
		{
			hobj = history_set(action_lib_animate)
			hobj.value_default = array()
			hobj.parent_save_id = save_id_get(app)
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

		if (history_redo)
		{
			with (tl)
			{
				tl_value_copy_vec3(e_value.POS_X, value_default, history_data.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, history_data.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, history_data.value_default)
				tl_value_copy_vec3(e_value.POS_X, value, value_default)
				tl_value_copy_vec3(e_value.ROT_X, value, value_default)
				tl_value_copy_vec3(e_value.SCA_X, value, value_default)
				tl_set_parent(par, -1, true)
			}
		}
		else
		{
			with (hobj)
			{
				tl_value_copy_vec3(e_value.POS_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.ROT_X, value_default, tl.value_default)
				tl_value_copy_vec3(e_value.SCA_X, value_default, tl.value_default)
				parent = app
			}
		}

		if (place && !history_redo && setting_place_new && !keyboard_check(vk_shift) &&
			(tl.type != e_tl_type.SCENERY || tl.temp.scenery != null) &&
			(tl.type != e_tl_type.MODEL || tl.temp.model != null) &&
			!sceneryreplaceground &&
			tl.value_type[e_value_type.TRANSFORM_POS])
			app_start_place(tl, true)
	}
	
	tl_update_list()
	tl_update_matrix()
	project_update_counts()
}
