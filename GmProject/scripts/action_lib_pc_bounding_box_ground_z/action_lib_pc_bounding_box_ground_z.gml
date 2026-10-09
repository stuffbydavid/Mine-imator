function action_lib_pc_bounding_box_ground_z(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_bounding_box_ground_z, obj_edit.pc_bounding_box_ground_z, obj_edit.pc_bounding_box_ground_z * add + value, true)
	
	obj_edit.pc_bounding_box_ground_z = obj_edit.pc_bounding_box_ground_z * add + value
}
