/// action_tl_keyframes_sound_resize_start()
/// @desc Sets position + soundstart + soundend

with (obj_keyframe)
{
	if (!selected)
		continue
	
	if (tl.type != "audio" || value[SOUNDOBJ] = null || !value[SOUNDOBJ].ready) // Only affects sounds
	{
		sound_resize_index = null
		continue
	}
	
	sound_resize_index = index
	sound_resize_pos = position
	sound_resize_start = value[SOUNDSTART]
}

timeline_sound_resize_mouse_pos = timeline_mouse_pos
window_busy = "timelineresizesounds"
