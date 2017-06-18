/// action_tl_keyframes_sound_resize()

var movex = timeline_mouse_pos - timeline_sound_resize_mousepos;

with (obj_keyframe)
{
    if (!select || soundresizeindex < 0)
        continue
    
    // Calculate new position
    newpos = max(0, soundresizepos + movex)
    newstart = soundresizestart + movex / app.project_tempo
    
    if (newstart < 0 || pos = newpos)
        continue
    
    // Remove from old
    with (tl)
        tl_keyframes_pushup(other.index)
}

// Re - add to new positions
with (obj_keyframe)
{
    if (!select || soundresizeindex < 0 || newstart < 0 || pos = newpos)
        continue
		
    value[SOUNDSTART] = newstart

    with (tl)
	{
        tl_keyframe_add(other.newpos, other.id)
        update_matrix = true
    }
}
