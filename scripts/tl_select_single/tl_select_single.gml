/// tl_select_single()
/// @desc Deselects all but the given timeline.

function tl_select_single()
{
	// Deselect all other timelines
	with (obj_timeline)
	{
		if (id = other.id)
			continue
		
		selected = false
		keyframe_select = null
		keyframe_select_amount = 0
		parent_is_selected = false
	}
	
	// Deselect all other keyframes
	with (obj_keyframe)
	{
		if (id.timeline = other.id)
			continue
		
		selected = false
	}
	
	tl_edit_amount = 1
	tl_edit = id
	
	selected = true
	tl_update_parent_is_selected()
}
