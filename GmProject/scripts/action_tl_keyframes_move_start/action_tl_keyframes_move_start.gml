/// action_tl_keyframes_move_start(keyframe)
/// @arg keyframe

function action_tl_keyframes_move_start(keyframe)
{
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		move_index = ds_list_find_index(timeline.keyframe_list, id)
		move_pos = position
	}
	
	timeline_move_kf = keyframe
	timeline_move_kf_mouse_pos = timeline_mouse_pos
	window_busy = "timelinemovekeyframes"
}
