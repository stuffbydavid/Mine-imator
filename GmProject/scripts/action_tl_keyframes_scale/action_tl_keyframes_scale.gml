/// action_tl_keyframes_scale()

function action_tl_keyframes_scale()
{
	var stretch;
	stretch = clamp(1 + (timeline_mouse_pos - timeline_scale_mouse_pos) / timeline_scale_span, 0, timeline_scale_max)
	
	tl_keyframes_stretch(timeline_scale_pivot, stretch)
	
	// Remove from old
	with (obj_keyframe)
	{
		if (!selected || position = new_position)
			continue
		
		ds_list_delete_value(timeline.keyframe_list, id)
	}
	
	// Re-add to new positions
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
}
