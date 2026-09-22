/// action_tl_keyframes_scale_cancel()
/// @desc Returns the selected keyframes to where they were before scaling.

function action_tl_keyframes_scale_cancel()
{
	with (obj_keyframe)
	{
		if (!selected)
			continue
		
		new_position = move_pos
		
		if (position = new_position)
			continue
		
		ds_list_delete_value(timeline.keyframe_list, id)
	}
	
	with (obj_keyframe)
	{
		if (!selected || position = new_position)
			continue
		
		with (timeline)
		{
			tl_keyframe_add(other.new_position, other.id)
			update_matrix = true
		}
	}
	
	window_busy = ""
	tl_update_length()
}
