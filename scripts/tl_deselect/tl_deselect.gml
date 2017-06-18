/// tl_deselect()

if (!select)
    return 0

select = false
if (keyframe_select)
    for (var k = 0; k < keyframe_amount; k++)
        keyframe[k].select = false

keyframe_select = null
keyframe_select_amount = 0

tl_edit_amount--
tl_edit = null
with (obj_timeline)
    if (select)
        tl_edit = id

tl_update_value_types_show()
tl_update_parent_is_select()
