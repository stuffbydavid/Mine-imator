function action_tl_create_temp()
{
	var hobj, roottl, newtemp;
	hobj = null
	roottl = null
	newtemp = null

	if (history_undo)
	{
		// Restore timeline ownership
		roottl = save_id_find(history_data.tl_save_id)
		newtemp = save_id_find(history_data.temp_save_id)
		if (roottl = null || newtemp = null)
			return 0

		tl_copy_temp(newtemp, roottl)

		with (roottl)
		{
			if (type = e_tl_type.SPECIAL_BLOCK)
				temp_update_model_timeline_parts()
			tl_update()
		}

		with (newtemp)
			instance_destroy()
	}
	else
	{
		if (history_redo)
			roottl = save_id_find(history_data.tl_save_id)
		else
			roottl = tl_edit

		if (roottl = null || roottl.has_temp || roottl.part_root != null ||
			roottl.type >= e_temp_type.amount || type_is_templated(roottl.type))
			return 0

		if (!history_redo)
		{
			hobj = history_set(action_tl_create_temp)
			hobj.tl_save_id = roottl.save_id
		}

		// Create template
		newtemp = new_obj(obj_template)
		tl_copy_temp(roottl, newtemp)

		with (newtemp)
		{
			if (type = e_temp_type.SPECIAL_BLOCK)
				temp_update_model_shape()
			
			temp_update_rot_point()
			temp_update_display_name()
			
			temp_add_lists()
			temp_select_edit(false)
		}

		with (roottl)
			tl_update()

		if (!history_redo)
			hobj.temp_save_id = newtemp.save_id
	}

	tl_update_list()
	tl_update_matrix()
	
	app_update_tl_edit()
	project_update_counts()
	
	lib_preview.update = true
}
