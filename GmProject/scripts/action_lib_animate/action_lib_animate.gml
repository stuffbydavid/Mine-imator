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
		var hobj, tl, sceneryreplaceground;
		hobj = null
		sceneryreplaceground = false
		
		if (history_redo)
		{
			hobj = history_data
			sceneryreplaceground = history_data.scenery_replace_ground
		}
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

		if (history_redo)
		{
			with (tl)
			{
				value_default[e_value.POS_X] = history_data.value_default[e_value.POS_X]
				value_default[e_value.POS_Y] = history_data.value_default[e_value.POS_Y]
				value_default[e_value.POS_Z] = history_data.value_default[e_value.POS_Z]
				value_default[e_value.ROT_X] = history_data.value_default[e_value.ROT_X]
				value_default[e_value.ROT_Y] = history_data.value_default[e_value.ROT_Y]
				value_default[e_value.ROT_Z] = history_data.value_default[e_value.ROT_Z]
				value[e_value.POS_X] = value_default[e_value.POS_X]
				value[e_value.POS_Y] = value_default[e_value.POS_Y]
				value[e_value.POS_Z] = value_default[e_value.POS_Z]
				value[e_value.ROT_X] = value_default[e_value.ROT_X]
				value[e_value.ROT_Y] = value_default[e_value.ROT_Y]
				value[e_value.ROT_Z] = value_default[e_value.ROT_Z]
				tl_set_parent(history_data.parent)
			}
		}
		else
		{
			with (hobj)
			{
				value_default[e_value.POS_X] = tl.value_default[e_value.POS_X]
				value_default[e_value.POS_Y] = tl.value_default[e_value.POS_Y]
				value_default[e_value.POS_Z] = tl.value_default[e_value.POS_Z]
				value_default[e_value.ROT_X] = tl.value_default[e_value.ROT_X]
				value_default[e_value.ROT_Y] = tl.value_default[e_value.ROT_Y]
				value_default[e_value.ROT_Z] = tl.value_default[e_value.ROT_Z]
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
