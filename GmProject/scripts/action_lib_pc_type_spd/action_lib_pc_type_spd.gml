/// action_lib_pc_type_spd(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_spd(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spd, ptype_edit.spd[axis_edit], ptype_edit.spd[axis_edit] * add + val, true)
	
	ptype_edit.spd[axis_edit] = ptype_edit.spd[axis_edit] * add + val
}
