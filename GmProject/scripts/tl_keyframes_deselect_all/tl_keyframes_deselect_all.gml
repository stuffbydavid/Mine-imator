/// tl_keyframes_deselect_all()
/// @desc Deselects all keyframes.

function tl_keyframes_deselect_all()
{
	with (obj_timeline)
	{
		keyframe_select = null
		keyframe_select_amount = 0
	}
	
	with (obj_keyframe)
		selected = false
}
