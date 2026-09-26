/// action_tl_frame_path_obj(path)
/// @arg path

function action_tl_frame_path_obj(path)
{
	var hobj, targets, oldpos, olddefault;
	if (history_undo || history_redo)
	{
		hobj = history_data
		tl_value_set()

		for (var t = 0; t < hobj.path_reset_amount; t++)
		{
			with (save_id_find(hobj.path_reset_save_id[t]))
			{
				var pos, defaultpos;
				pos = app.history_undo ? hobj.path_old_pos[t] : vec3(0)
				defaultpos = app.history_undo ? hobj.path_old_default_pos[t] : vec3(0)
				tl_value_set_vec3(e_value.POS_X, pos)
				tl_value_set_vec3(e_value.POS_X, defaultpos, true)
				
				if (!app.history_undo && ds_list_size(keyframe_list) > 0)
					with (keyframe_list[|0])
						tl_value_set_vec3(e_value.POS_X, vec3(0))
				
				update_matrix = true
			}
		}

		tl_update_matrix()
		return 0
	}

	targets = array()
	oldpos = array()
	olddefault = array()
	
	if (path != null)
	{
		with (obj_timeline)
		{
			if (selected && ds_list_size(keyframe_list) = 0)
			{
				array_add(targets, id)
				array_add(oldpos, tl_value_get_vec3(e_value.POS_X))
				array_add(olddefault, tl_value_get_vec3(e_value.POS_X, true))
			}
		}
	}

	tl_value_set_start(action_tl_frame_path_obj, false)
	hobj = history_data
	hobj.path_reset_amount = array_length(targets)
	if (hobj.path_reset_amount > 0)
		hobj.script = action_tl_frame_path_obj
	
	for (var t = 0; t < hobj.path_reset_amount; t++)
	{
		hobj.path_reset_save_id[t] = save_id_get(targets[t])
		hobj.path_old_pos[t] = oldpos[t]
		hobj.path_old_default_pos[t] = olddefault[t]
	}

	tl_value_set(e_value.PATH_OBJ, path, false)
	for (var t = 0; t < hobj.path_reset_amount; t++)
	{
		with (targets[t])
		{
			tl_value_set_vec3(e_value.POS_X, vec3(0))
			tl_value_set_vec3(e_value.POS_X, vec3(0), true)
			if (ds_list_size(keyframe_list) > 0)
				with (keyframe_list[|0])
					tl_value_set_vec3(e_value.POS_X, vec3(0))
			update_matrix = true
		}
	}
	
	tl_value_set_done()
}
