/// action_lib_pc_bounding_box_ground_z(value, add)
/// @arg value
/// @arg add

function action_lib_pc_bounding_box_ground_z(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_ground_z, temp_edit.pc_bounding_box_ground_z, temp_edit.pc_bounding_box_ground_z * add + val, true)
	
	temp_edit.pc_bounding_box_ground_z = temp_edit.pc_bounding_box_ground_z * add + val
}
