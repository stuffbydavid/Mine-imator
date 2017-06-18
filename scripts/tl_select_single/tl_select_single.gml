/// tl_select_single()
/// @desc Deselects all but the given timeline.

with (obj_timeline) // Deselect all other timelines
{
	if (id = other.id)
		continue
		
	select = false
	keyframe_select = null
	keyframe_select_amount = 0
	parent_is_select = false
}

with (obj_keyframe) // Deselect all other keyframes
{
	if (id.tl = other.id)
		continue
	
	select = false
}

tl_edit_amount = 1
tl_edit = id

select = true
tl_update_parent_is_select()
