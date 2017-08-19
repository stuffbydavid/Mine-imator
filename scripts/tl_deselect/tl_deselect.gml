/// tl_deselect()

if (!selected)
	return 0

selected = false
if (keyframe_select)
	for (var k = 0; k < ds_list_size(keyframe_list); k++)
		keyframe_list[|k].selected = false

keyframe_select = null
keyframe_select_amount = 0

tl_edit_amount--
tl_edit = null
with (obj_timeline)
	if (selected)
		tl_edit = id

tl_update_value_types_show()
tl_update_parent_is_selected()
