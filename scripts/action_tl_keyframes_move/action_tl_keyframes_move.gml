/// action_tl_keyframes_move()

var movex, moved;
movex = timeline_mouse_pos - timeline_move_kf_mouse_pos
moved = false

with (obj_keyframe)
{
	if (!selected)
		continue
	
	// Calculate new position
	new_position = max(0, move_pos + movex)
	if (position = new_position)
		continue
	
	// Remove from old
	ds_list_delete_value(timeline.keyframe_list, id)
}

// Re-add to new positions
with (obj_keyframe)
{
	if (!selected || position = new_position)
		continue
	
	moved = true

	with (timeline)
	{
		tl_keyframe_add(other.new_position, other.id)
		update_matrix = true
	}
}

if (moved)
{
	if (timeline_move_kf.timeline.type = e_tl_type.AUDIO && timeline_move_kf.value[e_value.SOUND_OBJ])
		timeline_marker = timeline_mouse_pos
	else
		timeline_marker = timeline_move_kf.position
}
