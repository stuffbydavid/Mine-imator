/// action_lib_pc_bounding_box_ground_z(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	history_set_var(action_lib_pc_bounding_box_ground_z, temp_edit.pc_bounding_box_ground_z, temp_edit.pc_bounding_box_ground_z * add + val, true)
}

temp_edit.pc_bounding_box_ground_z = temp_edit.pc_bounding_box_ground_z * add + val
