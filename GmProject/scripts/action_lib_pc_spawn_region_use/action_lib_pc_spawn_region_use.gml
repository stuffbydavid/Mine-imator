function action_lib_pc_spawn_region_use(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_region_use, obj_edit.pc_spawn_region_use, enabled, false)
	
	obj_edit.pc_spawn_region_use = enabled
}
