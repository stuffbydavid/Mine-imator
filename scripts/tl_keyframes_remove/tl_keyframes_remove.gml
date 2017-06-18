/// tl_keyframes_remove()

with (obj_keyframe) // Remove all selected
{
	if (!select)
		continue
	
	tl_keyframe_remove(id)
}

with (obj_timeline)
{
	if (!select || !keyframe_select)
		continue
	
	tl_deselect()
	update_matrix = true
}
