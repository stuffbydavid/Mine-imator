/// @desc Edits a world selection boundary without reloading its scenery.

function action_res_world_box(value, add = false)
{
	var axis, oldval, combine;
	axis = axis_edit mod 3

	if (axis_edit < 3)
		oldval = res_edit.world_box_start[axis]
	else
		oldval = res_edit.world_box_end[axis]

	if (add && !history_undo && !history_redo)
		value += oldval

	if (axis_edit < 3)
		value = min(round(value), res_edit.world_box_end[axis] - 1)
	else
		value = max(round(value), res_edit.world_box_start[axis] + 1)

	if (!history_undo && !history_redo)
	{
		if (value = oldval)
			return 0

		combine = history_amount > 0 && history[0].save_res_edit = save_id_get(res_edit)
		history_set_var(action_res_world_box, oldval, value, combine)
	}

	if (axis_edit < 3)
		res_edit.world_box_start[axis] = value
	else
		res_edit.world_box_end[axis] = value
}
