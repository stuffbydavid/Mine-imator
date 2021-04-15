/// action_tl_keyframe_next()

var pos = no_limit;

with (obj_timeline)
{
	if (!selected && tl_edit_amount > 0)
		continue
	
	if (keyframe_next != null && (keyframe_next.position > app.timeline_marker))
		pos = min(pos, keyframe_next.position)
}

if (pos != no_limit)
	timeline_marker = pos
