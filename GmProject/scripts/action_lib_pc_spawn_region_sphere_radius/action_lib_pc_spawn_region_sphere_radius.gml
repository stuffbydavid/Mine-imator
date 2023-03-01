/// action_lib_pc_spawn_region_sphere_radius(value, add)
/// @arg value
/// @arg add

function action_lib_pc_spawn_region_sphere_radius(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_region_sphere_radius, temp_edit.pc_spawn_region_sphere_radius, temp_edit.pc_spawn_region_sphere_radius * add + val, true)
	
	temp_edit.pc_spawn_region_sphere_radius = temp_edit.pc_spawn_region_sphere_radius * add + val
}
