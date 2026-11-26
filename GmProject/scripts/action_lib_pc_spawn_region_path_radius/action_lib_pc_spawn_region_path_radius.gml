function action_lib_pc_spawn_region_path_radius(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_region_path_radius, obj_edit.pc_spawn_region_path_radius, obj_edit.pc_spawn_region_path_radius * add + value, true)
	
	obj_edit.pc_spawn_region_path_radius = obj_edit.pc_spawn_region_path_radius * add + value
}
