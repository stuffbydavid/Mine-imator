function action_lib_pc_type_rot_spd_extend(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_spd_extend, ptype_edit.rot_spd_extend, enabled, false)
	
	ptype_edit.rot_spd_extend = enabled
}
