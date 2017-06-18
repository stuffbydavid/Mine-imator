/// tl_value_set_start(script, combine)
/// @arg script
/// @arg combine

var script, combine;
script = argument0
combine = argument1

with (app)
{
	action_toolbar_play_break()
	timeline_marker = round(timeline_marker)
}

// Used only in here
with (obj_keyframe)
{
	edit = select
	created = false
}

// Add new keyframe_amount
with (obj_timeline)
{
	if (!select)
		continue
		
	if (!keyframe_select)
	{
		// If marker is on a keyframe, edit that, if not, add new keyframe
		if (keyframe_current && keyframe_current.pos = app.timeline_marker && !keyframe_current.select)
			keyframe_current.edit = true
		else
		{
			var newkf = tl_keyframe_add(app.timeline_marker);
			newkf.created = true
			newkf.edit = true
			combine = false
		}
	}
}

// Register history
history_pop()
if (combine && history_amount > 0 &&
	history[0].parscript = script &&
	history[0].save_axis_edit = axis_edit)
	history_data = history[0]
else
{
	history_push()
	
	history_data = new_history(tl_value_set)
	history_data.parscript = script
	
	history_data.par_set_amount = 0
	history_data.kf_add_amount = 0
	history_data.kf_set_amount = 0
	
	with (obj_keyframe)
	{
		if (created)
		{
			history_data.kf_add_tl[history_data.kf_add_amount] = iid_get(tl)
			history_data.kf_add_index[history_data.kf_add_amount] = index
			history_data.kf_add_pos[history_data.kf_add_amount] = pos
			history_data.kf_add_amount++
		}
		if (edit)
		{
			history_data.kf_set_tl[history_data.kf_set_amount] = iid_get(tl)
			history_data.kf_set_index[history_data.kf_set_amount] = index
			history_data.kf_set_amount++
		}
	}
	
	history[0] = history_data

	log("Action", script_get_name(script))
}

history_data.par_set_n = 0
