/// tl_deselect_all()
/// @desc Deselects all timelines and keyframes.

function tl_deselect_all()
{
	with (obj_timeline)
	{
		if (selected)
		{
			tl_update_value_types_show()
			selected = false
			keyframe_select = null
			keyframe_select_amount = 0
		}
		
		parent_is_selected = false
	}
	
	with (obj_keyframe)
		selected = false
	
	tl_edit_amount = 0
	tl_edit = null
	
	if (instance_exists(obj_edit) && obj_edit.object_index = obj_timeline)
		obj_edit = null
}
