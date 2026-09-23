/// action_tl_keyframes_scale_start()
/// @desc Starts scaling the selected keyframes around the playhead.

function action_tl_keyframes_scale_start()
{
	var selamount, selmin, selmax, pivot;
	selamount = 0
	selmin = no_limit
	selmax = -no_limit
	
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		move_index = ds_list_find_index(timeline.keyframe_list, id)
		move_pos = position
		selamount++
		selmin = min(selmin, position)
		selmax = max(selmax, position)
	}
	
	if (selamount < 2 || selmax = selmin)
		return 0
	
	pivot = floor(timeline_marker)
	
	timeline_scale_pivot = pivot
	timeline_scale_span = selmax - selmin
	timeline_scale_mouse_pos = timeline_mouse_pos
	timeline_scale_max = no_limit
	
	// Stop the selection from being pushed past frame 0
	if (selmin < pivot)
		timeline_scale_max = pivot / (pivot - selmin)
	
	action_tl_play_break()
	window_focus = "timeline"
	window_busy = "timelinescalekeyframes"
}
