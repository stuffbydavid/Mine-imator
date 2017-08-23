/// action_lib_pc_type_rot_spd_add_random_min(value, add)
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
	history_set_var(action_lib_pc_type_rot_spd_add_random_min, ptype_edit.rot_spd_add_random_min[axis_edit], ptype_edit.rot_spd_add_random_min[axis_edit] * add + val, true)
}

ptype_edit.rot_spd_add_random_min[axis_edit] = ptype_edit.rot_spd_add_random_min[axis_edit] * add + val
