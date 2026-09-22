/// action_tl_animated(enable)
/// @arg enable

function action_tl_animated(enable)
{
	var hobj, blocked, blockedpart, count, targets;
	blocked = false
	blockedpart = false
	count = 0

	if (history_undo || history_redo)
	{
		hobj = history_data
		for (var t = 0; t < hobj.tl_amount; t++)
		{
			with (save_id_find(hobj.tl_save_id[t]))
			{
				if (hobj.kf_pos[t] != null)
				{
					if (app.history_undo)
					{
						var kf = tl_keyframe_add(hobj.kf_pos[t]);
						for (var v = 0; v < e_value.amount; v++)
							kf.value[v] = tl_value_find_save_id(v, null, hobj.kf_value[t, v])
						if (hobj.kf_selected[t])
							tl_keyframe_select(kf)
					}
					else
					{
						keyframe_select = null
						keyframe_select_amount = 0
						with (keyframe_list[|0])
							instance_destroy()
					}
				}

				if (app.history_undo)
				{
					animated = hobj.old_animated[t]
					hide = hobj.old_hide[t]
					for (var v = 0; v < e_value.amount; v++)
					{
						value_default[v] = tl_value_find_save_id(v, null, hobj.old_default[t, v])
						value[v] = tl_value_find_save_id(v, null, hobj.tl_animated_old_value[t, v])
					}
				}
				else
				{
					animated = hobj.new_animated[t]
					hide = hobj.new_hide[t]
					for (var v = 0; v < e_value.amount; v++)
					{
						value_default[v] = tl_value_find_save_id(v, null, hobj.new_default[t, v])
						value[v] = tl_value_find_save_id(v, null, hobj.tl_animated_new_value[t, v])
					}
				}
				
				tl_update_values()
				update_matrix = true
			}
		}
	}
	else
	{
		// Apply setting to all model parts
		targets = array()
		with (obj_timeline)
		{
			var part = id;
			while (part != null && !part.selected)
				part = part.part_of
			
			if (part = null || animated = enable || type = e_tl_type.AUDIO_TRACK || type = e_tl_type.BACKGROUND)
				continue
			
			if (!enable && ds_list_size(keyframe_list) > 1)
			{
				if (!selected)
					blockedpart = true
				else
					blocked = true
			}
			else
				array_add(targets, id)
		}
		
		count = array_length(targets)
		if (count > 0)
		{
			hobj = history_set(action_tl_animated)
			hobj.tl_amount = 0
			for (var i = 0; i < count; i++)
			{
				with (targets[i])
				{
					var t = hobj.tl_amount;
					hobj.tl_save_id[t] = save_id
					hobj.old_animated[t] = animated
					hobj.new_animated[t] = enable
					hobj.old_hide[t] = hide
					hobj.kf_pos[t] = null
				
					for (var v = 0; v < e_value.amount; v++)
					{
						hobj.old_default[t, v] = tl_value_get_save_id(v, value_default[v])
						hobj.tl_animated_old_value[t, v] = tl_value_get_save_id(v, value[v])
					}

					if (!enable && ds_list_size(keyframe_list) = 1)
					{
						var kf = keyframe_list[|0];
						hobj.kf_pos[t] = kf.position
						hobj.kf_selected[t] = kf.selected
						if (!kf.value[e_value.VISIBLE])
							hide = selected
						for (var v = 0; v < e_value.amount; v++)
						{
							hobj.kf_value[t, v] = tl_value_get_save_id(v, kf.value[v])
							value[v] = kf.value[v]
						}
						
						keyframe_select = null
						keyframe_select_amount = 0
						with (kf)
							instance_destroy()
					}
					else if (enable)
						value_default = array_copy_1d(value)

					if (!enable)
						value[e_value.VISIBLE] = true

					hobj.new_hide[t] = hide
					animated = enable
					tl_update_values()
					for (var v = 0; v < e_value.amount; v++)
					{
						hobj.new_default[t, v] = tl_value_get_save_id(v, value_default[v])
						hobj.tl_animated_new_value[t, v] = tl_value_get_save_id(v, value[v])
					}
					update_matrix = true
					hobj.tl_amount++
				}
			}
		}
		
		// Show notification about forbidden changes
		if (blocked)
			toast_new(e_toast.WARNING, text_get(tl_edit_amount > 1 ? "alertanimatedmultiple" : "alertanimated"))
		
		else if (blockedpart)
			toast_new(e_toast.INFO, text_get("alertanimatedpart"))
	}

	if (count > 0 || history_undo || history_redo)
	{
		tl_update_length()
		tl_update_matrix()
		if (setting_timeline_hide_nonanimated)
			tl_update_list()

		app_update_tl_edit()
		project_update_counts()
	}
}
