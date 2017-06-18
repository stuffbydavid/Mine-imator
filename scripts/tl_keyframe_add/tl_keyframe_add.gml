/// tl_keyframe_add(position, [keyframe])
/// @arg position
/// @arg keyframe
/// @desc Adds a new keyframe (or existing, if submitted) to the timeline.

var pos, kf, i;
pos = argument[0]
if (argument_count > 1)
	kf = argument[1]
else
	kf = null

// Find index
for (i = 0; i < keyframe_amount; i++)
{
	if (keyframe[i].pos = pos) // Find next empty slot
	{
		while (i < keyframe_amount)
		{
			if (keyframe[i].pos != pos)
				break
			i++
			pos++
		}
		break
	}
	if (keyframe[i].pos > pos)
		break
}

tl_keyframes_pushdown(i)
app.timeline_length = max(app.timeline_length, pos)

// Set new keyframe
if (kf < 0)
{
	kf = new(obj_keyframe)
	kf.select = false
	for (var v = 0; v < values; v++)
		kf.value[v] = value[v] // Get current parameters
	if (kf.value[SOUNDOBJ])
		kf.value[SOUNDOBJ].count++
}
kf.pos = pos
kf.tl = id
kf.index = i
kf.sound_play_index = null
keyframe[i] = kf
keyframe_next = keyframe_current
keyframe_current = kf

return kf
