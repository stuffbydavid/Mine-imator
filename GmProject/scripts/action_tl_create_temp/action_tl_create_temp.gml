/// action_tl_create_temp()

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

		with (newtemp)
			tl_create_temp_copy(roottl)

		if (roottl.type = e_tl_type.BLOCK)
		{
			roottl.block_vbuffer = newtemp.block_vbuffer
			newtemp.block_vbuffer = null
		}
		else if (roottl.type = e_tl_type.SPECIAL_BLOCK)
			with (newtemp)
				tl_create_temp_move_model(roottl)
		
		with (newtemp)
			tl_create_temp_move_pattern_update(roottl)

		with (obj_timeline)
		{
			if (temp != newtemp)
				continue

			id.temp = roottl
			has_temp = false
		}

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
		with (roottl)
			tl_create_temp_copy(newtemp)

		// Move runtime ownership
		if (roottl.type = e_tl_type.BLOCK)
		{
			newtemp.block_vbuffer = roottl.block_vbuffer
			roottl.block_vbuffer = null
		}
		else if (roottl.type = e_tl_type.SPECIAL_BLOCK)
			with (roottl)
				tl_create_temp_move_model(newtemp)
		
		with (roottl)
			tl_create_temp_move_pattern_update(newtemp)

		// Link the timeline hierarchy
		with (obj_timeline)
		{
			if (temp != roottl)
				continue

			id.temp = newtemp
			has_temp = true
		}

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
