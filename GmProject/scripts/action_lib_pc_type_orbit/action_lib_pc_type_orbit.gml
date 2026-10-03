function action_lib_pc_type_orbit(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_orbit, ptype_edit.orbit, enabled, false)
	
	ptype_edit.orbit = enabled
}
