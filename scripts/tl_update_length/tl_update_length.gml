/// tl_update_length()
/// @desc Updates the animation length.

var len = 0;
with (obj_timeline)
{
    if (keyframe_amount = 0)
        continue
		
    if (type = "audio")
	{
        for (var k = 0; k < keyframe_amount; k++)
            len = max(len, keyframe[k].pos + tl_keyframe_length(keyframe[k]))
    }
	else
        len = max(len, keyframe[keyframe_amount - 1].pos)
}

app.timeline_length = len
