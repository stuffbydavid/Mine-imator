/// tl_keyframe_deselect(keyframe)
/// @arg keyframe

function tl_keyframe_deselect(kf)
{
	if (!kf.selected)
		return 0
	
	kf.selected = false
	
	with (kf.timeline)
	{
		keyframe_select_amount--
		
		if (keyframe_select = kf)
		{
			keyframe_select = null
			with (obj_keyframe)
				if (selected && position = other.id)
					other.keyframe_select = id
		}
		
		if (!keyframe_select)
			tl_deselect()
	}
}
