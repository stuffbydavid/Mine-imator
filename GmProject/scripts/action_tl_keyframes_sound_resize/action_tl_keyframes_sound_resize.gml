/// action_tl_keyframes_sound_resize()

function action_tl_keyframes_sound_resize()
{
	var movex = timeline_mouse_pos - timeline_sound_resize_mouse_pos;
	
	with (obj_keyframe)
	{
		if (!selected || sound_resize_index < 0)
			continue
		
		// Calculate new position
		new_position = max(0, sound_resize_pos + movex)
		new_start = sound_resize_start + movex / app.project_tempo
		
		if (new_start < 0 || position = new_position)
			continue
		
		// Remove from old
		ds_list_delete_value(timeline.keyframe_list, id)
	}
	
	// Re-add to new positions
	with (obj_keyframe)
	{
		if (!selected || sound_resize_index < 0 || new_start < 0 || position = new_position)
			continue
		
		value[e_value.SOUND_START] = new_start
		
		with (timeline)
		{
			tl_keyframe_add(other.new_position, other.id)
			update_matrix = true
		}
	}
}
