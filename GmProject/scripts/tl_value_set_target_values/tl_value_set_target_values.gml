/// tl_value_set_target_values(vid, target_index_map, values)
/// @arg vid
/// @arg target_index_map
/// @arg values
/// @desc Applies a captured value per timeline through the normal keyframe and history path.

function tl_value_set_target_values(vid, target_index_map, values)
{
	var target_index;
	var tlcount = 0;

	with (obj_timeline)
	{
		if (!selected)
			continue

		var timeline_save_id = save_id_get(id);
		if (!ds_map_exists(target_index_map, timeline_save_id))
			continue
		target_index = target_index_map[?timeline_save_id]

		if (history_data.par_set_n = history_data.par_set_amount)
			history_data.tl_set_old_value[tlcount, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])

		var nval = tl_value_clamp(vid, values[target_index]);
		if (value[vid] != nval)
			update_matrix = true
		value[vid] = nval
		history_data.tl_set_new_value[tlcount, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])
		tlcount++
	}

	for (var k = 0; k < history_data.kf_set_amount; k++)
	{
		var timeline_save_id = history_data.kf_set_tl_save_id[k];
		if (!ds_map_exists(target_index_map, timeline_save_id))
			continue
		target_index = target_index_map[?timeline_save_id]

		with (save_id_find(timeline_save_id).keyframe_list[|history_data.kf_set_index[k]])
		{
			if (history_data.par_set_n = history_data.par_set_amount)
				history_data.kf_set_old_value[k, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])

			value[vid] = tl_value_clamp(vid, values[target_index])
			history_data.kf_set_new_value[k, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])
		}
	}

	history_data.value[history_data.par_set_n] = vid
	history_data.par_set_n++
	history_data.par_set_amount = max(history_data.par_set_amount, history_data.par_set_n)
}
