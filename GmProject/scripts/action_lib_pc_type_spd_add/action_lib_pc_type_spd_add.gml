/// action_lib_pc_type_spd_add(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_spd_add(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spd_add, ptype_edit.spd_add[axis_edit], ptype_edit.spd_add[axis_edit] * add + val, true)
	
	ptype_edit.spd_add[axis_edit] = ptype_edit.spd_add[axis_edit] * add + val
}
