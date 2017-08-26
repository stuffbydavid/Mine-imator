/// action_tl_keyframes_sound_resize_start()
/// @desc Sets position + soundstart + soundend

with (obj_keyframe)
{
	if (!selected)
		continue
	
	if (timeline.type != "audio" || value[e_value.SOUND_OBJ] = null || !value[e_value.SOUND_OBJ].ready) // Only affects sounds
	{
		sound_resize_index = null
		continue
	}
	
	sound_resize_index = ds_list_find_index(timeline.keyframe_list, id)
	sound_resize_pos = position
	sound_resize_start = value[e_value.SOUND_START]
}

timeline_sound_resize_mouse_pos = timeline_mouse_pos
window_busy = "timelineresizesounds"
