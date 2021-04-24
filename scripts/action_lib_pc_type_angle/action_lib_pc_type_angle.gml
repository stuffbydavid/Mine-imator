/// action_lib_pc_type_angle(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_angle(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle, ptype_edit.angle[axis_edit], ptype_edit.angle[axis_edit] * add + val, true)
	
	ptype_edit.angle[axis_edit] = ptype_edit.angle[axis_edit] * add + val
}
