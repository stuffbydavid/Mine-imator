/// tl_keyframe_select(keyframe)
/// @arg keyframe

function tl_keyframe_select(kf)
{
	if (kf.selected)
		return 0
	
	kf.selected = true
	
	with (kf.timeline)
	{
		keyframe_select = kf
		keyframe_select_amount++
		tl_update_recursive_select()
		tl_select()
	}
}
