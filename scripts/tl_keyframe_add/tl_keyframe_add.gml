/// tl_keyframe_add(position, [keyframe])
/// @arg position
/// @arg [keyframe]
/// @desc Adds a new keyframe (or existing, if submitted) to the timeline.

var pos, kf, i;
pos = argument[0]
if (argument_count > 1)
	kf = argument[1]
else
	kf = null

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
	kf = new(obj_keyframe)
	kf.selected = false
	
	// Get current parameters
	for (var v = 0; v < values; v++)
		kf.value[v] = value[v] 
	
	if (kf.value[SOUNDOBJ])
		kf.value[SOUNDOBJ].count++
}

kf.position = pos
kf.timeline = id
kf.sound_play_index = null
ds_list_insert(keyframe_list, i, kf)

keyframe_next = keyframe_current
keyframe_current = kf

return kf
