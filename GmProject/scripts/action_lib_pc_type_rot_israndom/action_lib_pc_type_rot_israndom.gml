function action_lib_pc_type_rot_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_israndom, ptype_edit.rot_israndom[axis_edit], enabled, false)
	
	ptype_edit.rot_israndom[axis_edit] = enabled
}
