/// keyframe_event_destroy()

function keyframe_event_destroy()
{
	ds_list_delete_value(timeline.keyframe_list, id)
	
	if (value[e_value.SOUND_OBJ] != null)
		value[e_value.SOUND_OBJ].count--
	
	// Force bend cache to be cleared
	if (timeline.model_part != null)
		timeline.model_clear_bend_cache = true
}
