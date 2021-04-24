/// tl_keyframes_remove()
/// @desc Remove all selected keyframes.

function tl_keyframes_remove()
{
	with (obj_keyframe) 
		if (selected)
			instance_destroy()
	
	with (obj_timeline)
	{
		if (!selected || keyframe_select = null)
			continue
		
		tl_deselect()
		update_matrix = true
	}
}
