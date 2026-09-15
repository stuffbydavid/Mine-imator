/// tl_value_set_start(script, combine)
/// @arg script
/// @arg combine

function tl_value_set_start(script, combine)
{
	return tl_value_set_start_filtered(script, combine, 0, false)
}

/// tl_value_set_start_targets(script, combine, target_index_map)
/// @arg script
/// @arg combine
/// @arg target_index_map
/// @desc Starts a value edit for only the timelines captured by a viewport
/// transform. Mixed selections must not create unrelated keyframes/history.
function tl_value_set_start_targets(script, combine, target_index_map)
{
	return tl_value_set_start_filtered(script, combine, target_index_map, true)
}

function tl_value_set_start_filtered(script, combine, target_index_map, filter_targets)
{
	with (app)
	{
		action_tl_play_break()
		timeline_marker = round(timeline_marker)
	}
	
	// Used only in here
	with (obj_keyframe)
	{
		edit = selected && (!filter_targets || ds_map_exists(target_index_map, save_id_get(timeline)))
		created = false
	}
	
	// Add new keyframes
	with (obj_timeline)
	{
		if (!selected || keyframe_select != null)
			continue
		if (filter_targets && !ds_map_exists(target_index_map, save_id_get(id)))
			continue
		
		// If marker is on a keyframe, edit that, if not, add new keyframe
		if (keyframe_current && keyframe_current.position = app.timeline_marker && !keyframe_current.selected)
			keyframe_current.edit = true
		else
		{
			var newkf = tl_keyframe_add(app.timeline_marker);
			newkf.created = true
			newkf.edit = true
			combine = false
		}
	}
	
	// Register history
	history_pop()
	if (combine && history_amount > 0 &&
		history[0].par_script = script &&
		history[0].save_axis_edit = axis_edit)
		history_data = history[0]
	else
	{
		history_push()
		
		history_data = new_history(tl_value_set)
		history_data.par_script = script
		
		history_data.par_set_amount = 0
		history_data.kf_add_amount = 0
		history_data.kf_set_amount = 0
		
		with (obj_keyframe)
		{
			if (created)
			{
				history_data.kf_add_tl_save_id[history_data.kf_add_amount] = save_id_get(timeline)
				history_data.kf_add_index[history_data.kf_add_amount] = ds_list_find_index(timeline.keyframe_list, id)
				history_data.kf_add_pos[history_data.kf_add_amount] = position
				history_data.kf_add_amount++
			}
			
			if (edit)
			{
				history_data.kf_set_tl_save_id[history_data.kf_set_amount] = save_id_get(timeline)
				history_data.kf_set_index[history_data.kf_set_amount] = ds_list_find_index(timeline.keyframe_list, id)
				history_data.kf_set_created[history_data.kf_set_amount] = created
				history_data.kf_set_amount++
			}
		}
		
		history[0] = history_data
		
		log("Action", script_get_name(script))
	}
	
	history_data.par_set_n = 0
	render_samples = -1
	history_resource_update = true
	return 0
}
