/// action_lib_pc_bounding_box_custom_start(value, add)
/// @arg value
/// @arg add

function action_lib_pc_bounding_box_custom_start(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_custom_start, temp_edit.pc_bounding_box_custom_start[axis_edit], temp_edit.pc_bounding_box_custom_start[axis_edit] * add + val, true)
	
	temp_edit.pc_bounding_box_custom_start[axis_edit] = temp_edit.pc_bounding_box_custom_start[axis_edit] * add + val
}
