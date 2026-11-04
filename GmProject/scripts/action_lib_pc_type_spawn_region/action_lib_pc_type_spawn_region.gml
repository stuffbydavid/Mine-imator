function action_lib_pc_type_spawn_region(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spawn_region, ptype_edit.spawn_region, enabled, false)
	
	ptype_edit.spawn_region = enabled
}
