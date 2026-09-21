/// action_tl_keyframes_move_start(keyframe)
/// @arg keyframe

function action_tl_keyframes_move_start(keyframe)
{
	var selamount, selmin, selmax, list, rowfirst, rowlast, kf, isleft, isright;
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
	
	timeline_move_kf = keyframe
	timeline_move_kf_mouse_pos = timeline_mouse_pos
	timeline_move_kf_stretch = false
	timeline_move_kf_stretch_pivot = 0
	timeline_move_kf_stretch_handle = 0
	timeline_move_kf_stretch_max = no_limit
	
	// Alt + dragging the first or last selected keyframe of a row stretches from the opposite edge
	if (keyboard_check(vk_alt) && selamount > 1 && selmax > selmin)
	{
		list = keyframe.timeline.keyframe_list
		rowfirst = null
		rowlast = null
		
		for (var k = 0; k < ds_list_size(list); k++)
		{
			kf = list[|k]
			
			if (!kf.selected)
				continue
			
			if (rowfirst = null)
				rowfirst = kf
			
			rowlast = kf
		}
		
		isleft = (keyframe = rowfirst)
		isright = (keyframe = rowlast)
		
		// Only selected keyframe in its row, use the nearest edge
		if (isleft && isright)
		{
			isleft = (keyframe.position - selmin < selmax - keyframe.position)
			isright = !isleft
		}
		
		if (isleft || isright)
		{
			timeline_move_kf_stretch_pivot = (isright ? selmin : selmax)
			timeline_move_kf_stretch_handle = keyframe.position
			
			if (timeline_move_kf_stretch_handle != timeline_move_kf_stretch_pivot)
			{
				timeline_move_kf_stretch = true
				
				// Stop the selection from being pushed past frame 0
				if (isleft)
					timeline_move_kf_stretch_max = selmax / (selmax - selmin)
			}
		}
	}
	
	window_busy = "timelinemovekeyframes"
}
