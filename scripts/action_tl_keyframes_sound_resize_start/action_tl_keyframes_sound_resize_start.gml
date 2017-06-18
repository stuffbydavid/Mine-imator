/// action_tl_keyframes_sound_resize_start()
/// @desc Sets position + soundstart + soundend

with (obj_keyframe)
{
	if (!select)
		continue
	
	if (tl.type != "audio" || !value[SOUNDOBJ] || !value[SOUNDOBJ].ready) // Only affects sounds
	{
		soundresizeindex = null
		continue
	}
	
	soundresizeindex = index
	soundresizepos = pos
	soundresizestart = value[SOUNDSTART]
}

timeline_sound_resize_mousepos = timeline_mouse_pos
window_busy = "timelineresizesounds"
