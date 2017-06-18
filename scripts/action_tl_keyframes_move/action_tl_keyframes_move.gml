/// action_tl_keyframes_move()

var movex, moved;
movex = timeline_mouse_pos - timeline_move_kf_mousepos
moved = false

with (obj_keyframe)
{
    if (!select)
        continue
    
    // Calculate new position
    newpos = max(0, movepos + movex)
    if (pos = newpos)
        continue
    
    // Remove from old
    with (tl)
        tl_keyframes_pushup(other.index)
}

// Re-add to new positions
with (obj_keyframe)
{
    if (!select || pos = newpos)
        continue
    moved = true

    with (tl)
	{
        tl_keyframe_add(other.newpos, other.id)
        update_matrix = true
    }
}

if (moved)
{
    if (timeline_move_kf.tl.type = "audio" && timeline_move_kf.value[SOUNDOBJ])
        timeline_marker = timeline_mouse_pos
    else
        timeline_marker = timeline_move_kf.pos
}
