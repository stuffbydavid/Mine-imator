/// action_tl_keyframe_previous()

var pos, prevpos, index;
pos = 0
prevpos = 0

with (obj_timeline)
{
	if (!selected && tl_edit_amount > 0)
		continue
	
	if (keyframe_current != null && (keyframe_current.position != app.timeline_marker))
		pos = max(pos, keyframe_current.position)
}

// Look for previous keyframes
with (obj_timeline)
{
	if (!selected && tl_edit_amount > 0)
		continue
		
	if (keyframe_current != null)
	{
		index = ds_list_find_index(keyframe_list, keyframe_current)
			
		if (index > 0)
			prevpos = max(prevpos, keyframe_list[|index - 1].position)
	}
}

if (prevpos > pos)
	pos = prevpos

timeline_marker = pos
