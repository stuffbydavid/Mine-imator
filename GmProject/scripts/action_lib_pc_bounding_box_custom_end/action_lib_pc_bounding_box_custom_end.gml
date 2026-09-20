/// action_lib_pc_bounding_box_custom_end(value, add)
/// @arg value
/// @arg add

function action_lib_pc_bounding_box_custom_end(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_custom_end, obj_edit.pc_bounding_box_custom_end[axis_edit], obj_edit.pc_bounding_box_custom_end[axis_edit] * add + val, true)
	
	obj_edit.pc_bounding_box_custom_end[axis_edit] = obj_edit.pc_bounding_box_custom_end[axis_edit] * add + val
}
