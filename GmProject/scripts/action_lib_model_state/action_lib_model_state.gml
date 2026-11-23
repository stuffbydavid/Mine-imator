function action_lib_model_state(value)
{
	var hobj, states;
	hobj = null
	
	if (history_undo)
		value = history_data.old_value
	else if (history_redo)
		value = history_data.new_value
	else
	{
		if (is_undefined(menu_model_state) || menu_model_state = null)
			return null

		states = model_set_state(obj_edit.model_state, menu_model_state.name, value)
		if (states = null)
			return 0

		hobj = history_set_var(action_lib_model_state, array_copy_1d(obj_edit.model_state), states, false)
		value = states
		with (hobj)
		{
			tl_amount = 0
			part_child_amount = 0
			history_save_tl_select()
		}

		// Find affected timelines
		with (obj_timeline)
		{
			if (temp != obj_edit || part_list = null)
				continue
			
			with (hobj)
			{
				tl_save_id[tl_amount] = save_id_get(other.id)

				// Save IDs of parts
				for (var p = 0; p < ds_list_size(other.part_list); p++)
					tl_part_old_save_id[tl_amount, p] = save_id_get(other.part_list[|p])
				
				tl_amount++
			}
		}
	}
	
	for (var i = 0; i < array_length(value); i += 2)
		if (state_vars_get_value(obj_edit.model_state, value[i]) != value[i + 1])
			asset_picker_set_state(value[i], value[i + 1])

	asset_picker_state_map[?mc_assets.model_name_map[?obj_edit.model_name]] = array_copy_1d(value)

	with (obj_edit)
	{
		if (object_index != obj_timeline)
			tl_deselect_all()
			
		model_state = array_copy_1d(value)
		
		temp_update_model()
		temp_update_model_timeline_tree(hobj)
		temp_update_model_shape()
		temp_update_display_name()
		
		model_shape_update_color()
		
		if (object_index = obj_timeline && id != app.place_tl)
			tl_select_single()
	}
	
	if (history_undo)
	{
		with (history_data)
		{
			// Restore old save IDs
			for (var t = 0; t < tl_amount; t++) 
				with (save_id_find(tl_save_id[t]))
					for (var p = 0; p < ds_list_size(part_list); p++)
						part_list[|p].save_id = history_data.tl_part_old_save_id[t, p]
			
			// Restore child positions in tree
			for (var m = 0; m < part_child_amount; m++) 
				with (save_id_find(part_child_save_id[m]))
					tl_set_parent(save_id_find(history_data.part_child_parent_save_id[m]), history_data.part_child_parent_tree_index[m])
			
			// Restore selection
			history_restore_tl_select()
		}
	}
	else if (history_redo)
	{
		// Restore new save IDs
		with (history_data)
			for (var t = 0; t < tl_amount; t++) 
				with (save_id_find(tl_save_id[t]))
					for (var p = 0; p < ds_list_size(part_list); p++)
						part_list[|p].save_id = history_data.tl_part_new_save_id[t, p]
	}
	else
	{
		// Save new IDs
		with (hobj)
			for (var t = 0; t < tl_amount; t++)
				with (save_id_find(tl_save_id[t]))
					for (var p = 0; p < ds_list_size(part_list); p++)
						hobj.tl_part_new_save_id[t, p] = save_id_get(part_list[|p])
	}
	
	app_update_tl_edit()
	
	tl_update_list()
	tl_update_matrix()
	
	lib_preview.update = true
}
