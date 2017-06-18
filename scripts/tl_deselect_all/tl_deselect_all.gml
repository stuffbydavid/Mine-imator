/// tl_deselect_all()
/// @desc Deselects all timelines and keyframes.

with (obj_timeline)
{
    if (select)
	{
        tl_update_value_types_show()
        select = false
        keyframe_select = null
        keyframe_select_amount = 0
    }
    parent_is_select = false
}

with (obj_keyframe)
    select = false

tl_edit_amount = 0
tl_edit = null
