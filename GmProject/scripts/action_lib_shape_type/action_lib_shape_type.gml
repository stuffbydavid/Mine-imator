/// action_lib_shape_type(type)
/// @arg type

function action_lib_shape_type(temptype)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_type, temp_edit.type, temptype, false)

	with (temp_edit)
	{
		type = temptype
		with (obj_timeline)
			if (temp = other.id && part_of = null)
				type = other.type
		temp_update()
	}

	lib_preview.update = true
}
