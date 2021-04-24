/// tl_update_length()
/// @desc Updates the animation length.

function tl_update_length()
{
	var len = 0;
	
	with (obj_timeline)
	{
		if (ds_list_size(keyframe_list) = 0)
			continue
		
		if (type = e_tl_type.AUDIO)
		{
			for (var k = 0; k < ds_list_size(keyframe_list); k++)
				len = max(len, keyframe_list[|k].position + tl_keyframe_length(keyframe_list[|k]))
		}
		else
			len = max(len, keyframe_list[|ds_list_size(keyframe_list) - 1].position)
	}
	
	app.timeline_length = len
}
