/// tl_keyframe_add(position, [keyframe])
/// @arg position
/// @arg [keyframe]
/// @desc Adds a new keyframe (or existing, if submitted) to the timeline.

function tl_keyframe_add(pos, kf = null)
{
	var i;
	
	// Find index
	for (i = 0; i < ds_list_size(keyframe_list); i++)
	{
		if (keyframe_list[|i].position = pos) // Find next empty slot
		{
			while (i < ds_list_size(keyframe_list))
			{
				if (keyframe_list[|i].position != pos)
					break
				i++
				pos++
			}
			break
		}
		if (keyframe_list[|i].position > pos)
			break
	}
	
	app.timeline_length = max(app.timeline_length, pos)
	
	// Set new keyframe
	if (kf < 0)
	{
		kf = new_obj(obj_keyframe)
		kf.selected = false
		
		// Get current parameters
		for (var v = 0; v < e_value.amount; v++)
			kf.value[v] = value[v] 
		
		if (kf.value[e_value.SOUND_OBJ] != null)
			kf.value[e_value.SOUND_OBJ].count++
	}
	
	kf.position = pos
	kf.timeline = id
	kf.sound_play_index = null
	ds_list_insert(keyframe_list, i, kf)
	
	keyframe_next = keyframe_current
	keyframe_current = kf
	
	return kf
}
